unit ujsonprotocol;

interface

uses
  System.SysUtils, System.JSON, System.Classes, System.Generics.Collections,
  Data.DB, System.Variants, System.StrUtils,
  uappdefines, uapptypes, uapputils;

type
  TJSONProtocol = class
  public
    class function BuildAuthRequest(const AUserName, APassword: string): string;
    class function BuildOpenDataRequest(const ASQL: string; AParams: TStrings;
      APageIndex, APageSize: Integer; const AToken: string): string;
    class function BuildExecCommandRequest(const ASQL: string;
      AParams: TStrings; const AToken: string): string;
    class function BuildApplyChangesRequest(const ATableName, AKeyFields: string;
      AChanges: TList<TChangeInfo>; const AToken: string): string;
    class function BuildGenericRequest(const AAction: string;
      AParams: TJSONObject; const AToken: string): string;

    class function ParseResponse(const AJSON: string): TJSONResponse;
    class function ParseMetaToFieldDefs(const AMetaJSON: string): TList<TFieldDefInfo>;
    class function ParseRowsToDictList(const ARowsJSON: string): TList<TRowData>;
    class function ResponseToJSON(const AResp: TJSONResponse): string;

    class function ReadErrorMsg(const AJSON: string): string;
    class function ReadSuccess(const AJSON: string): Boolean;
    class function ReadTotalCount(const AJSON: string): Integer;
    class function ReadReturnData(const AJSON: string): string;
  end;

implementation

class function TJSONProtocol.BuildAuthRequest(const AUserName, APassword: string): string;
var
  JSON: TJSONObject;
  Params: TJSONObject;
begin
  Params := TJSONObject.Create;
  Params.AddPair('UserName', AUserName);
  Params.AddPair('Password', APassword);

  JSON := TJSONObject.Create;
  JSON.AddPair('Action', ACTION_AUTH);
  JSON.AddPair('Token', '');
  JSON.AddPair('Params', Params);

  Result := JSON.ToJSON;
  JSON.Free;
end;

class function TJSONProtocol.BuildOpenDataRequest(const ASQL: string;
  AParams: TStrings; APageIndex, APageSize: Integer; const AToken: string): string;
var
  JSON: TJSONObject;
  Params, SQLParams: TJSONObject;
  ParamArr: TJSONArray;
  I: Integer;
  Obj: TJSONObject;
begin
  ParamArr := TJSONArray.Create;
  if AParams <> nil then
  begin
    for I := 0 to AParams.Count - 1 do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('Name', AParams.Names[I]);
      Obj.AddPair('Value', TJSONString.Create(AParams.ValueFromIndex[I]));
      Obj.AddPair('DataType', 'ftString');
      ParamArr.AddElement(Obj);
    end;
  end;

  SQLParams := TJSONObject.Create;
  SQLParams.AddPair('SQL', ASQL);
  SQLParams.AddPair('Params', ParamArr);
  SQLParams.AddPair('PageIndex', TJSONNumber.Create(APageIndex));
  SQLParams.AddPair('PageSize', TJSONNumber.Create(APageSize));

  Params := TJSONObject.Create;
  Params.AddPair('Action', ACTION_OPENDATA);
  Params.AddPair('Token', AToken);
  Params.AddPair('Params', SQLParams);

  Result := Params.ToJSON;
  Params.Free;
end;

class function TJSONProtocol.BuildExecCommandRequest(const ASQL: string;
  AParams: TStrings; const AToken: string): string;
var
  JSON, Params: TJSONObject;
  ParamArr: TJSONArray;
  I: Integer;
  Obj: TJSONObject;
begin
  ParamArr := TJSONArray.Create;
  if AParams <> nil then
  begin
    for I := 0 to AParams.Count - 1 do
    begin
      Obj := TJSONObject.Create;
      Obj.AddPair('Name', AParams.Names[I]);
      Obj.AddPair('Value', TJSONString.Create(AParams.ValueFromIndex[I]));
      Obj.AddPair('DataType', 'ftString');
      ParamArr.AddElement(Obj);
    end;
  end;

  Params := TJSONObject.Create;
  Params.AddPair('SQL', ASQL);
  Params.AddPair('Params', ParamArr);

  JSON := TJSONObject.Create;
  JSON.AddPair('Action', ACTION_EXECCOMMAND);
  JSON.AddPair('Token', AToken);
  JSON.AddPair('Params', Params);

  Result := JSON.ToJSON;
  JSON.Free;
end;

class function TJSONProtocol.BuildApplyChangesRequest(const ATableName,
  AKeyFields: string; AChanges: TList<TChangeInfo>; const AToken: string): string;
var
  JSON, Params: TJSONObject;
  ChangesArr, ChangeObj: TJSONArray;
  Item, OldItem: TJSONObject;
  CI: TChangeInfo;
  JV: TJSONValue;
begin
  ChangesArr := TJSONArray.Create;
  for CI in AChanges do
  begin
    ChangeObj := TJSONArray.Create;
    ChangeObj.Add(CI.Kind);
    JV := TJSONObject.ParseJSONValue(CI.Data);
    if JV <> nil then
      ChangeObj.AddElement(JV.Clone as TJSONValue);
    JV.Free;

    if CI.OldData <> '' then
    begin
      JV := TJSONObject.ParseJSONValue(CI.OldData);
      if JV <> nil then
        ChangeObj.AddElement(JV.Clone as TJSONValue);
      JV.Free;
    end;
    ChangesArr.AddElement(ChangeObj);
  end;

  Params := TJSONObject.Create;
  Params.AddPair('TableName', ATableName);
  Params.AddPair('KeyFields', AKeyFields);
  Params.AddPair('Changes', ChangesArr);

  JSON := TJSONObject.Create;
  JSON.AddPair('Action', ACTION_APPLYCHANGES);
  JSON.AddPair('Token', AToken);
  JSON.AddPair('Params', Params);

  Result := JSON.ToJSON;
  JSON.Free;
end;

class function TJSONProtocol.BuildGenericRequest(const AAction: string;
  AParams: TJSONObject; const AToken: string): string;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  JSON.AddPair('Action', AAction);
  JSON.AddPair('Token', AToken);
  if AParams <> nil then
    JSON.AddPair('Params', AParams.Clone as TJSONObject);

  Result := JSON.ToJSON;
  JSON.Free;
end;

class function TJSONProtocol.ParseResponse(const AJSON: string): TJSONResponse;
var
  JV, JRoot: TJSONValue;
  JObj: TJSONObject;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Success := False;

  JRoot := TJSONObject.ParseJSONValue(AJSON);
  if JRoot = nil then Exit;

  if JRoot is TJSONObject then
  begin
    JObj := TJSONObject(JRoot);
    Result.Success := SafeLoadBool(JObj, 'Success', False);
    Result.Message := SafeLoadStr(JObj, 'Message', '');

    JV := JObj.GetValue('TotalCount');
    if (JV <> nil) and (JV is TJSONNumber) then
      Result.TotalCount := TJSONNumber(JV).AsInt;
    JV := JObj.GetValue('RowsAffected');
    if (JV <> nil) and (JV is TJSONNumber) then
      Result.RowsAffected := TJSONNumber(JV).AsInt;

    JV := JObj.GetValue('Meta');
    if (JV <> nil) and not (JV is TJSONNull) then
      Result.Meta := JV.ToJSON;

    JV := JObj.GetValue('Rows');
    if (JV <> nil) and not (JV is TJSONNull) then
      Result.Rows := JV.ToJSON;

    JV := JObj.GetValue('ReturnData');
    if (JV <> nil) and not (JV is TJSONNull) then
      Result.ReturnData := JV.ToJSON;
  end;
  JRoot.Free;
end;

class function TJSONProtocol.ParseMetaToFieldDefs(const AMetaJSON: string): TList<TFieldDefInfo>;
var
  JV: TJSONValue;
  JArr: TJSONArray;
  I: Integer;
  Item: TJSONObject;
  FDI: TFieldDefInfo;
begin
  Result := TList<TFieldDefInfo>.Create;
  if AMetaJSON = '' then Exit;

  JV := TJSONObject.ParseJSONValue(AMetaJSON);
  if JV = nil then Exit;

  if JV is TJSONArray then
  begin
    JArr := TJSONArray(JV);
    for I := 0 to JArr.Count - 1 do
    begin
      if JArr.Items[I] is TJSONObject then
      begin
        Item := TJSONObject(JArr.Items[I]);
        FDI.FieldName := SafeLoadStr(Item, 'FieldName', '');
        FDI.DataType := SafeLoadStr(Item, 'DataType', 'ftString');
        FDI.Size := SafeLoadInt(Item, 'Size', 0);
        FDI.Required := SafeLoadBool(Item, 'Required', False);
        Result.Add(FDI);
      end;
    end;
  end;
  JV.Free;
end;

class function TJSONProtocol.ParseRowsToDictList(const ARowsJSON: string): TList<TRowData>;
var
  JV: TJSONValue;
  JArr: TJSONArray;
  I, J: Integer;
  Item: TJSONObject;
  Pair: TJSONPair;
  Row: TRowData;
begin
  Result := TList<TRowData>.Create;
  if ARowsJSON = '' then Exit;

  JV := TJSONObject.ParseJSONValue(ARowsJSON);
  if JV = nil then Exit;

  if JV is TJSONArray then
  begin
    JArr := TJSONArray(JV);
    for I := 0 to JArr.Count - 1 do
    begin
      if JArr.Items[I] is TJSONObject then
      begin
        Item := TJSONObject(JArr.Items[I]);
        Row := TRowData.Create;
        for J := 0 to Item.Count - 1 do
        begin
          Pair := Item.Pairs[J];
          Row.AddOrSetValue(Pair.JsonString.Value, JSONToVar(Pair.JsonValue));
        end;
        Result.Add(Row);
      end;
    end;
  end;
  JV.Free;
end;

class function TJSONProtocol.ResponseToJSON(const AResp: TJSONResponse): string;
var
  JSON: TJSONObject;
begin
  JSON := TJSONObject.Create;
  JSON.AddPair('Success', TJSONBool.Create(AResp.Success));
  JSON.AddPair('Message', AResp.Message);
  JSON.AddPair('TotalCount', TJSONNumber.Create(AResp.TotalCount));
  JSON.AddPair('RowsAffected', TJSONNumber.Create(AResp.RowsAffected));
  Result := JSON.ToJSON;
  JSON.Free;
end;

class function TJSONProtocol.ReadErrorMsg(const AJSON: string): string;
begin
  Result := ParseResponse(AJSON).Message;
end;

class function TJSONProtocol.ReadSuccess(const AJSON: string): Boolean;
begin
  Result := ParseResponse(AJSON).Success;
end;

class function TJSONProtocol.ReadTotalCount(const AJSON: string): Integer;
begin
  Result := ParseResponse(AJSON).TotalCount;
end;

class function TJSONProtocol.ReadReturnData(const AJSON: string): string;
begin
  Result := ParseResponse(AJSON).ReturnData;
end;

end.
