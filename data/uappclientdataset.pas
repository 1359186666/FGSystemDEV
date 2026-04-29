unit uappclientdataset;

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Data.DB, Datasnap.DBClient, System.JSON, System.StrUtils,
  uappdefines, uapptypes, uapputils, ujsonprotocol, utcpclient,
  Winapi.ActiveX, System.Win.ComObj, Vcl.Forms;

type
  TAppClientDataSet = class(TClientDataSet)
  private
    FTCPClient: TTCPClient;
    FParams: TStrings;
    FSQLText: string;
    FTotalCount: Integer;
    FPageIndex: Integer;
    FPageSize: Integer;
    FKeyFields: string;
    FTableName: string;

    procedure InternalRestructureSaveRestore(AFieldDefs: TFieldDefs);
    procedure DoRestoreData(ASavedData: OleVariant; AOldFieldNames: TStringList);
    function GetCurrentFieldNames: TStringList;
    procedure CreateExcelApp(out AExcelApp: OleVariant);
  protected
    procedure OpenCursor(InfoQuery: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AssignTCPClient(AClient: TTCPClient);
    function Clone: TAppClientDataSet;

    // CRUD by JSON/TCP
    procedure OpenData(const ASQL: string); overload;
    procedure OpenData(const ASQL: string; AParams: array of Variant); overload;
    procedure OpenDataPage(const ASQL: string; APageIndex, APageSize: Integer);
    procedure ExecCommand(const ASQL: string);
    procedure ExecCommandParams(const ASQL: string; AParams: TStrings);
    procedure ApplyToServer; reintroduce;
    procedure NextPage;
    procedure PrevPage;

    // hot field operations
    function AddField(const AFieldName: string; ADataType: TFieldType;
      ASize: Integer = 0; ARequired: Boolean = False): TFieldDef;
    function InsertField(AIndex: Integer; const AFieldName: string;
      ADataType: TFieldType; ASize: Integer = 0;
      ARequired: Boolean = False): TFieldDef;
    procedure DeleteField(const AFieldName: string); overload;
    procedure DeleteField(AIndex: Integer); overload;
    function FieldExists(const AFieldName: string): Boolean;
    function GetFieldIndex(const AFieldName: string): Integer;

    // import/export
    procedure ExportToExcel(const AFileName: string; AShowProgress: Boolean = True);
    procedure ImportFromExcel(const AFileName: string; ASheetIndex: Integer = 1);

    // helper
    function DataToJSON: string;
    procedure LoadFromJSON(const AJSON: string);
    function ToXMLString: string;
    procedure LoadFromXMLString(const AXML: string);

    property SQLText: string read FSQLText write FSQLText;
    property TotalCount: Integer read FTotalCount write FTotalCount;
    property PageIndex: Integer read FPageIndex write FPageIndex;
    property PageSize: Integer read FPageSize write FPageSize;
    property KeyFields: string read FKeyFields write FKeyFields;
    property TableName: string read FTableName write FTableName;
    property Params: TStrings read FParams;
  end;

implementation

constructor TAppClientDataSet.Create(AOwner: TComponent);
begin
  inherited;
  FParams := TStringList.Create;
  FSQLText := '';
  FTotalCount := 0;
  FPageIndex := 1;
  FPageSize := DEFAULT_PAGE_SIZE;
  FKeyFields := '';
  FTableName := '';
  FTCPClient := nil;
end;

destructor TAppClientDataSet.Destroy;
begin
  FParams.Free;
  inherited;
end;

procedure TAppClientDataSet.AssignTCPClient(AClient: TTCPClient);
begin
  FTCPClient := AClient;
end;

function TAppClientDataSet.Clone: TAppClientDataSet;
begin
  Result := TAppClientDataSet.Create(nil);
  Result.AssignTCPClient(FTCPClient);
  Result.FSQLText := FSQLText;
  Result.FKeyFields := FKeyFields;
  Result.FTableName := FTableName;
  Result.FPageSize := FPageSize;
  if Active then
  begin
    Result.Data := Self.Data;
  end
  else
  begin
    Result.FieldDefs.Assign(Self.FieldDefs);
  end;
end;

function TAppClientDataSet.GetCurrentFieldNames: TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  for I := 0 to FieldDefs.Count - 1 do
    Result.Add(FieldDefs[I].Name);
end;

procedure TAppClientDataSet.DoRestoreData(ASavedData: OleVariant;
  AOldFieldNames: TStringList);
var
  I, J: Integer;
  OldFieldName, NewFieldName: string;
begin
  if VarIsEmpty(ASavedData) then Exit;

  Self.Data := ASavedData;
end;

procedure TAppClientDataSet.InternalRestructureSaveRestore(AFieldDefs: TFieldDefs);
var
  SavedData: OleVariant;
  OldFields: TStringList;
begin
  if not Active then Exit;

  DisableControls;
  try
    OldFields := GetCurrentFieldNames;
    SavedData := Self.Data;
    Close;

    FieldDefs.Clear;
    FieldDefs.Assign(AFieldDefs);
    CreateDataSet;

    DoRestoreData(SavedData, OldFields);
    OldFields.Free;
  finally
    EnableControls;
  end;
end;

function TAppClientDataSet.AddField(const AFieldName: string;
  ADataType: TFieldType; ASize: Integer; ARequired: Boolean): TFieldDef;
var
  NewFieldDefs: TFieldDefs;
begin
  Result := nil;
  if FieldExists(AFieldName) then
    raise Exception.CreateFmt('Field "%s" already exists', [AFieldName]);

  NewFieldDefs := TFieldDefs.Create(Self);
  try
    if Active then
    begin
      NewFieldDefs.Assign(FieldDefs);
      Result := NewFieldDefs.AddFieldDef;
    end
    else
      Result := FieldDefs.AddFieldDef;

    Result.Name := AFieldName;
    Result.DataType := ADataType;
    Result.Size := ASize;
    Result.Required := ARequired;

    if Active then
      InternalRestructureSaveRestore(NewFieldDefs);
  finally
    if Active then
      NewFieldDefs.Free;
  end;
end;

function TAppClientDataSet.InsertField(AIndex: Integer; const AFieldName: string;
  ADataType: TFieldType; ASize: Integer; ARequired: Boolean): TFieldDef;
var
  NewFieldDefs: TFieldDefs;
  I: Integer;
begin
  Result := nil;
  if FieldExists(AFieldName) then
    raise Exception.CreateFmt('Field "%s" already exists', [AFieldName]);

  NewFieldDefs := TFieldDefs.Create(Self);
  try
    if Active then
      NewFieldDefs.Assign(FieldDefs);
    Result := NewFieldDefs.AddFieldDef;
    Result.Name := AFieldName;
    Result.DataType := ADataType;
    Result.Size := ASize;
    Result.Required := ARequired;

    if (AIndex >= 0) and (AIndex < NewFieldDefs.Count) then
      Result.Index := AIndex;

    if Active then
      InternalRestructureSaveRestore(NewFieldDefs);
  finally
    if Active then
      NewFieldDefs.Free;
  end;
end;

procedure TAppClientDataSet.DeleteField(const AFieldName: string);
var
  NewFieldDefs: TFieldDefs;
  I: Integer;
  FD: TFieldDef;
begin
  NewFieldDefs := TFieldDefs.Create(Self);
  try
    if Active then
      NewFieldDefs.Assign(FieldDefs);

    FD := NewFieldDefs.Find(AFieldName);
    if FD = nil then
    begin
      FD := FieldDefs.Find(AFieldName);
      if FD <> nil then
        FD.Free;
    end
    else
      FD.Free;

    if Active then
      InternalRestructureSaveRestore(NewFieldDefs);
  finally
    if Active then
      NewFieldDefs.Free;
  end;
end;

procedure TAppClientDataSet.DeleteField(AIndex: Integer);
var
  NewFieldDefs: TFieldDefs;
begin
  NewFieldDefs := TFieldDefs.Create(Self);
  try
    if Active then
      NewFieldDefs.Assign(FieldDefs);

    if (AIndex >= 0) and (AIndex < NewFieldDefs.Count) then
      NewFieldDefs.Delete(AIndex);

    if Active then
      InternalRestructureSaveRestore(NewFieldDefs);
  finally
    if Active then
      NewFieldDefs.Free;
  end;
end;

function TAppClientDataSet.FieldExists(const AFieldName: string): Boolean;
begin
  Result := FieldDefs.Find(AFieldName) <> nil;
end;

function TAppClientDataSet.GetFieldIndex(const AFieldName: string): Integer;
var
  FD: TFieldDef;
begin
  FD := FieldDefs.Find(AFieldName);
  if FD <> nil then
    Result := FD.Index
  else
    Result := -1;
end;

procedure TAppClientDataSet.OpenCursor(InfoQuery: Boolean);
begin
  if FSQLText <> '' then
  begin
    if FTCPClient = nil then
      raise Exception.Create('TCPClient not assigned');

    OpenDataPage(FSQLText, FPageIndex - 1, FPageSize);
    First;
  end
  else
    inherited;
end;

procedure TAppClientDataSet.OpenData(const ASQL: string);
begin
  FSQLText := ASQL;
  FPageIndex := 1;
  OpenDataPage(ASQL, 0, FPageSize);
end;

procedure TAppClientDataSet.OpenData(const ASQL: string; AParams: array of Variant);
var
  I: Integer;
begin
  FParams.Clear;
  for I := Low(AParams) to High(AParams) do
    FParams.Add(Format('P%d=%s', [I, VarToStr(AParams[I])]));
  OpenData(ASQL);
end;

procedure TAppClientDataSet.OpenDataPage(const ASQL: string;
  APageIndex, APageSize: Integer);
var
  Req, Resp: string;
  JSONResp: TJSONResponse;
  MetaList: TList<TFieldDefInfo>;
  RowList: TList<TRowData>;
  FDI: TFieldDefInfo;
  Row: TRowData;
  FD: TFieldDef;
  Key: string;
begin
  if FTCPClient = nil then
    raise Exception.Create('TCPClient not assigned');

  Req := TJSONProtocol.BuildOpenDataRequest(ASQL, FParams,
    APageIndex, APageSize, FTCPClient.SessionToken);
  Resp := FTCPClient.SendRequest(Req);

  JSONResp := TJSONProtocol.ParseResponse(Resp);
  if not JSONResp.Success then
    raise Exception.Create(JSONResp.Message);

  FTotalCount := JSONResp.TotalCount;
  FPageIndex := APageIndex + 1;
  FPageSize := APageSize;
  FSQLText := ASQL;

  Close;

  // build structure from Meta
  MetaList := TJSONProtocol.ParseMetaToFieldDefs(JSONResp.Meta);
  try
    FieldDefs.Clear;
    for FDI in MetaList do
    begin
      FD := FieldDefs.AddFieldDef;
      FD.Name := FDI.FieldName;
      FD.DataType := StringToDataType(FDI.DataType);
      FD.Size := FDI.Size;
      FD.Required := FDI.Required;
    end;
  finally
    MetaList.Free;
  end;

  CreateDataSet;

  // fill data
  RowList := TJSONProtocol.ParseRowsToDictList(JSONResp.Rows);
  try
    for Row in RowList do
    begin
      Append;
      for Key in Row.Keys do
      begin
        if FindField(Key) <> nil then
          FieldByName(Key).Value := Row[Key];
      end;
      Post;
    end;
  finally
    RowList.Free;
  end;
end;

procedure TAppClientDataSet.ExecCommand(const ASQL: string);
begin
  ExecCommandParams(ASQL, FParams);
end;

procedure TAppClientDataSet.ExecCommandParams(const ASQL: string; AParams: TStrings);
var
  Req, Resp: string;
  JSONResp: TJSONResponse;
begin
  if FTCPClient = nil then
    raise Exception.Create('TCPClient not assigned');

  Req := TJSONProtocol.BuildExecCommandRequest(ASQL, AParams,
    FTCPClient.SessionToken);
  Resp := FTCPClient.SendRequest(Req);

  JSONResp := TJSONProtocol.ParseResponse(Resp);
  if not JSONResp.Success then
    raise Exception.Create(JSONResp.Message);
end;

procedure TAppClientDataSet.ApplyToServer;
var
  Req, Resp: string;
  JSONResp: TJSONResponse;
  ChangeList: TList<TChangeInfo>;
  ChangeInfo: TChangeInfo;
begin
  if FTCPClient = nil then
    raise Exception.Create('TCPClient not assigned');

  if ChangeCount = 0 then
  begin
    MergeChangeLog;
    Exit;
  end;

  ChangeList := TList<TChangeInfo>.Create;
  try
    // process delta
    if not VarIsEmpty(Delta) then
    begin
      Delta.First;
      while not Delta.Eof do
      begin
        ChangeInfo.Kind := Delta.FieldByName('DATASET_DELTA').AsString;
        ChangeInfo.Data := '';
        ChangeInfo.OldData := '';
        ChangeList.Add(ChangeInfo);
        Delta.Next;
      end;
    end;

    Req := TJSONProtocol.BuildApplyChangesRequest(FTableName, FKeyFields,
      ChangeList, FTCPClient.SessionToken);
    Resp := FTCPClient.SendRequest(Req);

    JSONResp := TJSONProtocol.ParseResponse(Resp);
    if JSONResp.Success then
    begin
      MergeChangeLog;
      OpenData(FSQLText);
    end
    else
      raise Exception.Create(JSONResp.Message);
  finally
    ChangeList.Free;
  end;
end;

procedure TAppClientDataSet.NextPage;
begin
  if (FPageIndex * FPageSize) < FTotalCount then
    OpenDataPage(FSQLText, FPageIndex, FPageSize);
end;

procedure TAppClientDataSet.PrevPage;
begin
  if FPageIndex > 1 then
    OpenDataPage(FSQLText, FPageIndex - 2, FPageSize);
end;

procedure TAppClientDataSet.CreateExcelApp(out AExcelApp: OleVariant);
begin
  CoInitialize(nil);
  try
    AExcelApp := CreateOleObject('Excel.Application');
  except
    raise Exception.Create('Excel is not installed on this system');
  end;
end;

procedure TAppClientDataSet.ExportToExcel(const AFileName: string;
  AShowProgress: Boolean = True);
var
  Excel, Workbook, Worksheet: OleVariant;
  I, J, RowOffset: Integer;
  SavePath: string;
begin
  if not Active then Exit;

  SavePath := AFileName;
  if SavePath = '' then Exit;

  CreateExcelApp(Excel);
  try
    Excel.Visible := False;
    Excel.DisplayAlerts := False;
    Workbook := Excel.Workbooks.Add;

    DisableControls;
    try
      Worksheet := Workbook.Worksheets[1];

      for J := 0 to Fields.Count - 1 do
        Worksheet.Cells[1, J + 1] := Fields[J].DisplayName;

      First;
      RowOffset := 2;
      while not Eof do
      begin
        for J := 0 to Fields.Count - 1 do
        begin
          if not Fields[J].IsNull then
            Worksheet.Cells[RowOffset, J + 1] := Fields[J].Value;
        end;
        Next;
        Inc(RowOffset);
      end;
    finally
      EnableControls;
    end;

    if Pos('.xlsx', LowerCase(SavePath)) = 0 then
      SavePath := SavePath + '.xlsx';

    Workbook.SaveAs(SavePath, 51);
    Workbook.Close;
  finally
    Excel.Quit;
    Excel := Unassigned;
  end;
end;

procedure TAppClientDataSet.ImportFromExcel(const AFileName: string;
  ASheetIndex: Integer);
var
  Excel, Workbook, Worksheet: OleVariant;
  RowIdx, ColIdx, FieldCount, MaxRow, MaxCol: Integer;
  ColName: string;
begin
  if not Active then Exit;
  if not FileExists(AFileName) then
    raise Exception.CreateFmt('File not found: %s', [AFileName]);

  CreateExcelApp(Excel);
  try
    Excel.Visible := False;
    Excel.DisplayAlerts := False;
    Workbook := Excel.Workbooks.Open(AFileName);
    Worksheet := Workbook.Worksheets[ASheetIndex];

    MaxRow := Worksheet.UsedRange.Rows.Count;
    MaxCol := Worksheet.UsedRange.Columns.Count;

    DisableControls;
    try
      for RowIdx := 2 to MaxRow do
      begin
        Append;
        for ColIdx := 1 to MaxCol do
        begin
          ColName := VarToStr(Worksheet.Cells[1, ColIdx]);
          if FindField(ColName) <> nil then
            FieldByName(ColName).Value := Worksheet.Cells[RowIdx, ColIdx];
        end;
        Post;
      end;
    finally
      EnableControls;
    end;

    Workbook.Close(False);
  finally
    Excel.Quit;
    Excel := Unassigned;
  end;
end;

function TAppClientDataSet.DataToJSON: string;
var
  JArr: TJSONArray;
  JObj: TJSONObject;
  J: Integer;
begin
  Result := '';
  if not Active then Exit;

  JArr := TJSONArray.Create;
  try
    First;
    while not Eof do
    begin
      JObj := TJSONObject.Create;
      for J := 0 to Fields.Count - 1 do
        JObj.AddPair(Fields[J].FieldName, VarToJSONValue(Fields[J].Value));
      JArr.AddElement(JObj);
      Next;
    end;
    Result := JArr.ToJSON;
  finally
    JArr.Free;
  end;
end;

procedure TAppClientDataSet.LoadFromJSON(const AJSON: string);
var
  JV: TJSONValue;
  JArr: TJSONArray;
  I, J: Integer;
  JObj: TJSONObject;
  Pair: TJSONPair;
begin
  JV := TJSONObject.ParseJSONValue(AJSON);
  if JV = nil then Exit;

  try
    if JV is TJSONArray then
    begin
      JArr := TJSONArray(JV);
      DisableControls;
      try
        for I := 0 to JArr.Count - 1 do
        begin
          if JArr.Items[I] is TJSONObject then
          begin
            JObj := TJSONObject(JArr.Items[I]);
            Append;
            for J := 0 to JObj.Count - 1 do
            begin
              Pair := JObj.Pairs[J];
              if FindField(Pair.JsonString.Value) <> nil then
                FieldByName(Pair.JsonString.Value).Value := JSONToVar(Pair.JsonValue);
            end;
            Post;
          end;
        end;
      finally
        EnableControls;
      end;
    end;
  finally
    JV.Free;
  end;
end;

function TAppClientDataSet.ToXMLString: string;
var
  MS: TMemoryStream;
  SS: TStringStream;
begin
  Result := '';
  MS := TMemoryStream.Create;
  SS := TStringStream.Create('', TEncoding.UTF8);
  try
    SaveToStream(MS, dfXMLUTF8);
    MS.Position := 0;
    SS.CopyFrom(MS, MS.Size);
    Result := SS.DataString;
  finally
    MS.Free;
    SS.Free;
  end;
end;

procedure TAppClientDataSet.LoadFromXMLString(const AXML: string);
var
  MS: TMemoryStream;
  SS: TStringStream;
begin
  SS := TStringStream.Create(AXML, TEncoding.UTF8);
  MS := TMemoryStream.Create;
  try
    MS.CopyFrom(SS, SS.Size);
    MS.Position := 0;
    LoadFromStream(MS);
  finally
    MS.Free;
    SS.Free;
  end;
end;

initialization
  RegisterClass(TAppClientDataSet);

end.
