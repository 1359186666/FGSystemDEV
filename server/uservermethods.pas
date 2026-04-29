unit uservermethods;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  System.DateUtils, System.StrUtils,
  Data.DB, Data.SqlExpr,
  uappdefines, uapptypes, uapputils, ujsonprotocol, userverinit;

type
  TServerMethods = class
  private
    FServerInit: TServerInit;
    FSessions: TDictionary<string, TUserInfo>;
  public
    constructor Create(AServerInit: TServerInit);
    destructor Destroy; override;

    function HandleRequest(const ARequestJSON: string): string;
    function HandleAuth(const AParams: TJSONObject): string;
    function HandleOpenData(const AParams: TJSONObject): string;
    function HandleExecCommand(const AParams: TJSONObject): string;
    function HandleApplyChanges(const AParams: TJSONObject): string;

    function ValidateToken(const AToken: string): Boolean;
  end;

implementation

function BuildInsertSQL(const ATableName: string; AData: TJSONObject): string; forward;
function BuildUpdateSQL(const ATableName: string; AData, AOldData: TJSONObject;
  const AKeyFields: string): string; forward;
function BuildDeleteSQL(const ATableName: string; AData: TJSONObject;
  const AKeyFields: string): string; forward;
function QuotedStrOrNull(AValue: TJSONValue): string; forward;

constructor TServerMethods.Create(AServerInit: TServerInit);
begin
  inherited Create;
  FServerInit := AServerInit;
  FSessions := TDictionary<string, TUserInfo>.Create;
end;

destructor TServerMethods.Destroy;
begin
  FSessions.Free;
  inherited;
end;

function TServerMethods.ValidateToken(const AToken: string): Boolean;
begin
  Result := FSessions.ContainsKey(AToken);
end;

function TServerMethods.HandleRequest(const ARequestJSON: string): string;
var
  JV: TJSONValue;
  JObj: TJSONObject;
  Action, Token: string;
  Params: TJSONObject;
begin
  Result := '{"Success":false,"Message":"Invalid request"}';

  JV := TJSONObject.ParseJSONValue(ARequestJSON);
  if JV = nil then Exit;

  try
    if not (JV is TJSONObject) then Exit;

    JObj := TJSONObject(JV);
    Action := SafeLoadStr(JObj, 'Action', '');
    Token := SafeLoadStr(JObj, 'Token', '');

    Params := TJSONObject(JObj.GetValue('Params'));

    if (Action <> ACTION_AUTH) and not ValidateToken(Token) then
    begin
      Result := '{"Success":false,"Message":"Session expired"}';
      Exit;
    end;

    if Action = ACTION_AUTH then
      Result := HandleAuth(Params)
    else if Action = ACTION_OPENDATA then
      Result := HandleOpenData(Params)
    else if Action = ACTION_EXECCOMMAND then
      Result := HandleExecCommand(Params)
    else if Action = ACTION_APPLYCHANGES then
      Result := HandleApplyChanges(Params);
  finally
    JV.Free;
  end;
end;

function TServerMethods.HandleAuth(const AParams: TJSONObject): string;
var
  UserName, Password: string;
  Q: TSQLQuery;
  Token: string;
  UserInfo: TUserInfo;
  JResp: TJSONObject;
begin
  UserName := SafeLoadStr(AParams, 'UserName', '');
  Password := SafeLoadStr(AParams, 'Password', '');

  JResp := TJSONObject.Create;
  try
    if not FServerInit.IsConnected then
    begin
      JResp.AddPair('Success', TJSONBool.Create(False));
      JResp.AddPair('Message', 'Database not connected');
      Result := JResp.ToJSON;
      Exit;
    end;

    Q := FServerInit.CreateQuery;
    try
      Q.SQL.Text := Format(
        'SELECT UserID, UserName, RealName, PasswordHash, Status, IsSuperAdmin ' +
        'FROM sys_Users WHERE UserName = ''%s'' AND Status = 1',
        [StringReplace(UserName, '''', '''''', [rfReplaceAll])]);
      Q.Open;

      if Q.IsEmpty then
      begin
        JResp.AddPair('Success', TJSONBool.Create(False));
        JResp.AddPair('Message', 'Invalid username or password');
      end
      else if not VerifyPassword(Password, Q.FieldByName('PasswordHash').AsString) then
      begin
        JResp.AddPair('Success', TJSONBool.Create(False));
        JResp.AddPair('Message', 'Invalid username or password');
      end
      else
      begin
        Token := GenerateGUID;

        FillChar(UserInfo, SizeOf(UserInfo), 0);
        UserInfo.UserID := Q.FieldByName('UserID').AsInteger;
        UserInfo.UserName := Q.FieldByName('UserName').AsString;
        UserInfo.RealName := Q.FieldByName('RealName').AsString;
        UserInfo.Status := Q.FieldByName('Status').AsInteger;
        UserInfo.IsSuperAdmin := Q.FieldByName('IsSuperAdmin').AsInteger = 1;

        TMonitor.Enter(FSessions);
        try
          FSessions.AddOrSetValue(Token, UserInfo);
        finally
          TMonitor.Exit(FSessions);
        end;

        JResp.AddPair('Success', TJSONBool.Create(True));
        JResp.AddPair('Message', Token);
      end;

      Result := JResp.ToJSON;
    finally
      Q.Free;
    end;
  finally
    JResp.Free;
  end;
end;

function TServerMethods.HandleOpenData(const AParams: TJSONObject): string;
var
  SQL: string;
  PageIndex, PageSize: Integer;
  Q: TSQLQuery;
  JArr, JArrRows: TJSONArray;
  JObj: TJSONObject;
  JResp: TJSONObject;
  I, RowCount: Integer;
  Field: TField;
  CountQ: TSQLQuery;
begin
  SQL := SafeLoadStr(AParams, 'SQL', '');
  PageIndex := SafeLoadInt(AParams, 'PageIndex', 0);
  PageSize := SafeLoadInt(AParams, 'PageSize', DEFAULT_PAGE_SIZE);

  if SQL = '' then
  begin
    Result := '{"Success":false,"Message":"SQL is empty"}';
    Exit;
  end;

  JResp := TJSONObject.Create;
  try
    try
      // get total count
      CountQ := FServerInit.CreateQuery;
      try
        CountQ.SQL.Text := 'SELECT COUNT(*) AS CNT FROM (' + SQL + ') AS T';
        CountQ.Open;
        JResp.AddPair('TotalCount', TJSONNumber.Create(CountQ.FieldByName('CNT').AsInteger));
      finally
        CountQ.Free;
      end;

      // apply paging
      if PageSize > 0 then
        SQL := Format('SELECT * FROM (SELECT *, ROW_NUMBER() OVER (ORDER BY (SELECT 0)) AS __rn FROM (%s) AS __t) AS __p WHERE __rn BETWEEN %d AND %d',
          [SQL, PageIndex * PageSize + 1, (PageIndex + 1) * PageSize]);

      Q := FServerInit.CreateQuery;
      try
        Q.SQL.Text := SQL;
        Q.Open;

        // meta
        JArr := TJSONArray.Create;
        for I := 0 to Q.FieldCount - 1 do
        begin
          if SameText(Q.Fields[I].FieldName, '__rn') then Continue;

          JObj := TJSONObject.Create;
          JObj.AddPair('FieldName', Q.Fields[I].FieldName);
          JObj.AddPair('DataType', DataTypeToString(Q.Fields[I].DataType));
          JObj.AddPair('Size', TJSONNumber.Create(Q.Fields[I].Size));
          JObj.AddPair('Required', TJSONBool.Create(Q.Fields[I].Required));
          JArr.AddElement(JObj);
        end;
        JResp.AddPair('Meta', JArr);

        // rows
        JArrRows := TJSONArray.Create;
        Q.First;
        while not Q.Eof do
        begin
          JObj := TJSONObject.Create;
          for I := 0 to Q.FieldCount - 1 do
          begin
            if SameText(Q.Fields[I].FieldName, '__rn') then Continue;

            Field := Q.Fields[I];
            if Field.IsNull then
              JObj.AddPair(Field.FieldName, TJSONNull.Create)
            else
              JObj.AddPair(Field.FieldName, VarToJSONValue(Field.Value));
          end;
          JArrRows.AddElement(JObj);
          Q.Next;
        end;
        JResp.AddPair('Rows', JArrRows);

        JResp.AddPair('Success', TJSONBool.Create(True));
        JResp.AddPair('Message', '');
        JResp.AddPair('RowsAffected', TJSONNumber.Create(JArrRows.Count));
      finally
        Q.Free;
      end;
    except
      on E: Exception do
      begin
        JResp.AddPair('Success', TJSONBool.Create(False));
        JResp.AddPair('Message', E.Message);
      end;
    end;

    Result := JResp.ToJSON;
  finally
    JResp.Free;
  end;
end;

function TServerMethods.HandleExecCommand(const AParams: TJSONObject): string;
var
  SQL: string;
  Q: TSQLQuery;
  RowsAffected: Integer;
  JResp: TJSONObject;
begin
  SQL := SafeLoadStr(AParams, 'SQL', '');

  if SQL = '' then
  begin
    Result := '{"Success":false,"Message":"SQL is empty"}';
    Exit;
  end;

  JResp := TJSONObject.Create;
  try
    try
      Q := FServerInit.CreateQuery;
      try
        Q.SQL.Text := SQL;
        RowsAffected := Q.ExecSQL(False);
      finally
        Q.Free;
      end;

      JResp.AddPair('Success', TJSONBool.Create(True));
      JResp.AddPair('Message', '');
      JResp.AddPair('RowsAffected', TJSONNumber.Create(RowsAffected));
      JResp.AddPair('TotalCount', TJSONNumber.Create(0));
    except
      on E: Exception do
      begin
        JResp.AddPair('Success', TJSONBool.Create(False));
        JResp.AddPair('Message', E.Message);
      end;
    end;

    Result := JResp.ToJSON;
  finally
    JResp.Free;
  end;
end;

function TServerMethods.HandleApplyChanges(const AParams: TJSONObject): string;
var
  TableName, KeyFields: string;
  Changes: TJSONArray;
  I, RowsAffected: Integer;
  ChangeItem: TJSONArray;
  Kind: string;
  DataObj: TJSONObject;
  SQL: string;
  JResp: TJSONObject;
  OldData: TJSONObject;
begin
  TableName := SafeLoadStr(AParams, 'TableName', '');
  KeyFields := SafeLoadStr(AParams, 'KeyFields', '');

  JResp := TJSONObject.Create;
  try
    if TableName = '' then
    begin
      JResp.AddPair('Success', TJSONBool.Create(False));
      JResp.AddPair('Message', 'TableName is required');
      Result := JResp.ToJSON;
      Exit;
    end;

    RowsAffected := 0;
    try
      Changes := TJSONArray(AParams.GetValue('Changes'));
      if Changes <> nil then
      begin
        FServerInit.ExecSQL('BEGIN TRANSACTION');

        try
          for I := 0 to Changes.Count - 1 do
          begin
            ChangeItem := TJSONArray(Changes.Items[I]);
            Kind := ChangeItem.Items[0].Value;

            if SameText(Kind, 'Insert') then
            begin
              DataObj := TJSONObject(ChangeItem.Items[1]);
              SQL := BuildInsertSQL(TableName, DataObj);
              RowsAffected := RowsAffected + FServerInit.ExecSQL(SQL);
            end
            else if SameText(Kind, 'Modify') then
            begin
              DataObj := TJSONObject(ChangeItem.Items[1]);
              OldData := nil;
              if ChangeItem.Count > 2 then
                OldData := TJSONObject(ChangeItem.Items[2]);
              SQL := BuildUpdateSQL(TableName, DataObj, OldData, KeyFields);
              RowsAffected := RowsAffected + FServerInit.ExecSQL(SQL);
            end
            else if SameText(Kind, 'Delete') then
            begin
              DataObj := TJSONObject(ChangeItem.Items[1]);
              SQL := BuildDeleteSQL(TableName, DataObj, KeyFields);
              RowsAffected := RowsAffected + FServerInit.ExecSQL(SQL);
            end;
          end;

          FServerInit.ExecSQL('COMMIT TRANSACTION');
        except
          on E: Exception do
          begin
            FServerInit.ExecSQL('ROLLBACK TRANSACTION');
            raise;
          end;
        end;
      end;

      JResp.AddPair('Success', TJSONBool.Create(True));
      JResp.AddPair('Message', '');
      JResp.AddPair('RowsAffected', TJSONNumber.Create(RowsAffected));
    except
      on E: Exception do
      begin
        JResp.AddPair('Success', TJSONBool.Create(False));
        JResp.AddPair('Message', E.Message);
      end;
    end;

    Result := JResp.ToJSON;
  finally
    JResp.Free;
  end;
end;

function BuildInsertSQL(const ATableName: string; AData: TJSONObject): string;
var
  Fields, Values: TStringList;
  I: Integer;
  Pair: TJSONPair;
begin
  Fields := TStringList.Create;
  Values := TStringList.Create;
  try
    for I := 0 to AData.Count - 1 do
    begin
      Pair := AData.Pairs[I];
      Fields.Add(Pair.JsonString.Value);
      if Pair.JsonValue is TJSONNull then
        Values.Add('NULL')
      else if Pair.JsonValue is TJSONNumber then
        Values.Add(Pair.JsonValue.Value)
      else
        Values.Add('''' + StringReplace(Pair.JsonValue.Value, '''', '''''', [rfReplaceAll]) + '''');
    end;

    Result := Format('INSERT INTO %s (%s) VALUES (%s)',
      [ATableName, Fields.CommaText, Values.CommaText]);
  finally
    Fields.Free;
    Values.Free;
  end;
end;

function BuildUpdateSQL(const ATableName: string; AData, AOldData: TJSONObject;
  const AKeyFields: string): string;
var
  SetClause, WhereClause: TStringList;
  I: Integer;
  Pair: TJSONPair;
  Keys: TStringList;
  Key: string;
begin
  SetClause := TStringList.Create;
  WhereClause := TStringList.Create;
  try
    for I := 0 to AData.Count - 1 do
    begin
      Pair := AData.Pairs[I];
      SetClause.Add(Format('%s = %s', [Pair.JsonString.Value,
        QuotedStrOrNull(Pair.JsonValue)]));
    end;

    Keys := TStringList.Create;
    try
      ExtractStrings([','], [], PChar(AKeyFields), Keys);
      for Key in Keys do
      begin
        if (AOldData <> nil) and (AOldData.GetValue(Key) <> nil) then
          WhereClause.Add(Format('%s = %s', [Key,
            QuotedStrOrNull(AOldData.GetValue(Key))]))
        else if AData.GetValue(Key) <> nil then
          WhereClause.Add(Format('%s = %s', [Key,
            QuotedStrOrNull(AData.GetValue(Key))]));
      end;
    finally
      Keys.Free;
    end;

    Result := Format('UPDATE %s SET %s WHERE %s',
      [ATableName, SetClause.CommaText, WhereClause.CommaText]);
  finally
    SetClause.Free;
    WhereClause.Free;
  end;
end;

function BuildDeleteSQL(const ATableName: string; AData: TJSONObject;
  const AKeyFields: string): string;
var
  WhereClause: TStringList;
  Keys: TStringList;
  Key: string;
begin
  WhereClause := TStringList.Create;
  try
    Keys := TStringList.Create;
    try
      ExtractStrings([','], [], PChar(AKeyFields), Keys);
      for Key in Keys do
      begin
        if AData.GetValue(Key) <> nil then
          WhereClause.Add(Format('%s = %s', [Key,
            QuotedStrOrNull(AData.GetValue(Key))]));
      end;
    finally
      Keys.Free;
    end;

    Result := Format('DELETE FROM %s WHERE %s', [ATableName, WhereClause.CommaText]);
  finally
    WhereClause.Free;
  end;
end;

function QuotedStrOrNull(AValue: TJSONValue): string;
begin
  if (AValue = nil) or (AValue is TJSONNull) then
    Result := 'NULL'
  else if AValue is TJSONNumber then
    Result := AValue.Value
  else if AValue is TJSONBool then
  begin
    if TJSONBool(AValue).AsBoolean then
      Result := '1'
    else
      Result := '0';
  end
  else
    Result := '''' + StringReplace(AValue.Value, '''', '''''', [rfReplaceAll]) + '''';
end;

end.
