unit uconfigloader;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uapptypes, uappdefines, uapputils, uappclientdataset, utcpclient, uconfigtypes;

type
  TConfigLoader = class
  private
    FTCPClient: TTCPClient;
    FConfigCache: TDictionary<string, TModuleConfigData>;
  public
    constructor Create(ATCPClient: TTCPClient);
    destructor Destroy; override;

    function LoadModuleConfig(const AModuleName: string): TModuleConfigData;
    procedure ClearCache;
    procedure RefreshCache;

    // Individual table loaders
    function LoadModuleInfo(const AModuleName: string): TModuleConfig;
    function LoadDatasets(AModuleID: Integer): TList<TDataSetConfig>;
    function LoadGridColumns(ADatasetConfigID: Integer): TList<TGridColumnConfig>;
    function LoadPanelControls(AModuleID: Integer): TList<TPanelControlConfig>;
    function LoadLookups: TList<TLookupConfig>;
    function LoadButtons(AModuleID: Integer): TList<TButtonConfig>;
  end;

implementation

constructor TConfigLoader.Create(ATCPClient: TTCPClient);
begin
  inherited Create;
  FTCPClient := ATCPClient;
  FConfigCache := TDictionary<string, TModuleConfigData>.Create;
end;

destructor TConfigLoader.Destroy;
begin
  ClearCache;
  FConfigCache.Free;
  inherited;
end;

procedure TConfigLoader.ClearCache;
var
  Key: string;
begin
  for Key in FConfigCache.Keys do
    FConfigCache[Key].Free;
  FConfigCache.Clear;
end;

procedure TConfigLoader.RefreshCache;
begin
  ClearCache;
end;

function TConfigLoader.LoadModuleConfig(
  const AModuleName: string): TModuleConfigData;
var
  CDS: TAppClientDataSet;
  DSCfg: TDataSetConfig;
  GCCfg: TGridColumnConfig;
  PCCfg: TPanelControlConfig;
  LUCfg: TLookupConfig;
  BtnCfg: TButtonConfig;
  M: TModuleConfig;
begin
  if FConfigCache.TryGetValue(AModuleName, Result) then
    Exit;

  Result := TModuleConfigData.Create;

  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);

    // load module info
    CDS.OpenData(Format(
      'SELECT * FROM sys_ModuleConfig WHERE ModuleName = ''%s'' AND IsActive = 1',
      [AModuleName]));

    if CDS.RecordCount = 0 then
    begin
      FConfigCache.Add(AModuleName, Result);
      Exit;
    end;

    M := Result.Module;
    M.ID := CDS.FieldByName('ID').AsInteger;
    M.ModuleName := CDS.FieldByName('ModuleName').AsString;
    M.ModuleCaption := CDS.FieldByName('ModuleCaption').AsString;
    M.ModuleCode := CDS.FieldByName('ModuleCode').AsString;
    M.ParentMenuName := CDS.FieldByName('ParentMenuName').AsString;
    M.MenuIconIndex := CDS.FieldByName('MenuIconIndex').AsInteger;
    M.SortOrder := CDS.FieldByName('SortOrder').AsInteger;
    M.IsActive := True;
    Result.Module := M;

    // load datasets
    CDS.OpenData(Format(
      'SELECT * FROM sys_DataSetConfig WHERE ModuleID = %d',
      [Result.Module.ID]));

    CDS.First;
    while not CDS.Eof do
    begin
      DSCfg.ID := CDS.FieldByName('ID').AsInteger;
      DSCfg.ModuleID := Result.Module.ID;
      DSCfg.DatasetName := CDS.FieldByName('DatasetName').AsString;
      DSCfg.SQLText := CDS.FieldByName('SQLText').AsString;
      DSCfg.KeyFields := CDS.FieldByName('KeyFields').AsString;
      DSCfg.DefaultOrderBy := CDS.FieldByName('DefaultOrderBy').AsString;
      DSCfg.PageSize := CDS.FieldByName('PageSize').AsInteger;
      DSCfg.IsReadOnly := CDS.FieldByName('IsReadOnly').AsInteger = 1;
      DSCfg.MasterDatasetName := CDS.FieldByName('MasterDatasetName').AsString;
      DSCfg.MasterKeyFields := CDS.FieldByName('MasterKeyFields').AsString;

      Result.Datasets.Add(DSCfg);
      CDS.Next;
    end;

    // load grid columns
    CDS.OpenData(Format(
      'SELECT gc.* FROM sys_GridColumnConfig gc ' +
      'INNER JOIN sys_DataSetConfig ds ON gc.DatasetConfigID = ds.ID ' +
      'WHERE ds.ModuleID = %d ORDER BY gc.ColumnIndex',
      [Result.Module.ID]));

    CDS.First;
    while not CDS.Eof do
    begin
      GCCfg.ID := CDS.FieldByName('ID').AsInteger;
      GCCfg.DatasetConfigID := CDS.FieldByName('DatasetConfigID').AsInteger;
      GCCfg.FieldName := CDS.FieldByName('FieldName').AsString;
      GCCfg.ColumnCaption := CDS.FieldByName('ColumnCaption').AsString;
      GCCfg.ColumnIndex := CDS.FieldByName('ColumnIndex').AsInteger;
      GCCfg.ColumnWidth := CDS.FieldByName('ColumnWidth').AsInteger;
      GCCfg.Visible := CDS.FieldByName('Visible').AsInteger = 1;
      GCCfg.ReadOnly := CDS.FieldByName('ReadOnly').AsInteger = 1;
      GCCfg.Alignment := CDS.FieldByName('Alignment').AsString;
      GCCfg.DisplayFormat := CDS.FieldByName('DisplayFormat').AsString;
      GCCfg.IsLookup := CDS.FieldByName('IsLookup').AsInteger = 1;
      GCCfg.LookupDatasetID := CDS.FieldByName('LookupDatasetID').AsInteger;
      GCCfg.LookupKeyField := CDS.FieldByName('LookupKeyField').AsString;
      GCCfg.LookupDisplayField := CDS.FieldByName('LookupDisplayField').AsString;
      GCCfg.LookupListField := CDS.FieldByName('LookupListField').AsString;

      Result.GridColumns.Add(GCCfg);
      CDS.Next;
    end;

    // load panel controls
    CDS.OpenData(Format(
      'SELECT * FROM sys_PanelControlConfig WHERE ModuleID = %d ORDER BY TabOrder',
      [Result.Module.ID]));

    CDS.First;
    while not CDS.Eof do
    begin
      PCCfg.ID := CDS.FieldByName('ID').AsInteger;
      PCCfg.ModuleID := Result.Module.ID;
      PCCfg.DatasetName := CDS.FieldByName('DatasetName').AsString;
      PCCfg.PanelName := CDS.FieldByName('PanelName').AsString;
      PCCfg.FieldName := CDS.FieldByName('FieldName').AsString;
      PCCfg.ControlType := StringToControlType(CDS.FieldByName('ControlType').AsString);
      PCCfg.Caption := CDS.FieldByName('Caption').AsString;
      PCCfg.Left := CDS.FieldByName('Left').AsInteger;
      PCCfg.Top := CDS.FieldByName('Top').AsInteger;
      PCCfg.Width := CDS.FieldByName('Width').AsInteger;
      PCCfg.Height := CDS.FieldByName('Height').AsInteger;
      PCCfg.TabOrder := CDS.FieldByName('TabOrder').AsInteger;
      PCCfg.ReadOnly := CDS.FieldByName('ReadOnly').AsInteger = 1;
      PCCfg.Required := CDS.FieldByName('Required').AsInteger = 1;
      PCCfg.LookupDatasetID := CDS.FieldByName('LookupDatasetID').AsInteger;
      PCCfg.LookupKeyField := CDS.FieldByName('LookupKeyField').AsString;
      PCCfg.LookupDisplayField := CDS.FieldByName('LookupDisplayField').AsString;
      PCCfg.DefaultValue := CDS.FieldByName('DefaultValue').AsString;
      PCCfg.Visible := CDS.FieldByName('Visible').AsInteger = 1;

      Result.PanelControls.Add(PCCfg);
      CDS.Next;
    end;

    // load lookups
    CDS.OpenData('SELECT * FROM sys_LookupConfig ORDER BY ID');

    CDS.First;
    while not CDS.Eof do
    begin
      LUCfg.ID := CDS.FieldByName('ID').AsInteger;
      LUCfg.LookupName := CDS.FieldByName('LookupName').AsString;
      LUCfg.LookupCaption := CDS.FieldByName('LookupCaption').AsString;
      LUCfg.SQLText := CDS.FieldByName('SQLText').AsString;
      LUCfg.KeyField := CDS.FieldByName('KeyField').AsString;
      LUCfg.DisplayField := CDS.FieldByName('DisplayField').AsString;
      LUCfg.ListFields := CDS.FieldByName('ListFields').AsString;
      LUCfg.CacheExpireMin := CDS.FieldByName('CacheExpireMin').AsInteger;
      LUCfg.IsTreeData := CDS.FieldByName('IsTreeData').AsInteger = 1;

      Result.Lookups.Add(LUCfg);
      CDS.Next;
    end;

    // load buttons
    CDS.OpenData(Format(
      'SELECT * FROM sys_ButtonConfig WHERE ModuleID = %d ORDER BY ID',
      [Result.Module.ID]));

    CDS.First;
    while not CDS.Eof do
    begin
      BtnCfg.ID := CDS.FieldByName('ID').AsInteger;
      BtnCfg.ModuleID := Result.Module.ID;
      BtnCfg.ButtonName := CDS.FieldByName('ButtonName').AsString;
      BtnCfg.ButtonCaption := CDS.FieldByName('ButtonCaption').AsString;
      BtnCfg.ActionType := CDS.FieldByName('ActionType').AsString;
      BtnCfg.ToolbarGroup := CDS.FieldByName('ToolbarGroup').AsString;
      BtnCfg.ImageIndex := CDS.FieldByName('ImageIndex').AsInteger;
      BtnCfg.ShortCut := CDS.FieldByName('ShortCut').AsString;
      BtnCfg.Hint := CDS.FieldByName('Hint').AsString;

      Result.Buttons.Add(BtnCfg);
      CDS.Next;
    end;

  finally
    CDS.Free;
  end;

  FConfigCache.Add(AModuleName, Result);
end;

function TConfigLoader.LoadModuleInfo(const AModuleName: string): TModuleConfig;
var
  MCD: TModuleConfigData;
begin
  MCD := LoadModuleConfig(AModuleName);
  Result := MCD.Module;
end;

function TConfigLoader.LoadDatasets(AModuleID: Integer): TList<TDataSetConfig>;
var
  CDS: TAppClientDataSet;
  DSCfg: TDataSetConfig;
begin
  Result := TList<TDataSetConfig>.Create;

  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.OpenData(Format(
      'SELECT * FROM sys_DataSetConfig WHERE ModuleID = %d', [AModuleID]));

    CDS.First;
    while not CDS.Eof do
    begin
      DSCfg.ID := CDS.FieldByName('ID').AsInteger;
      DSCfg.DatasetName := CDS.FieldByName('DatasetName').AsString;
      DSCfg.SQLText := CDS.FieldByName('SQLText').AsString;
      DSCfg.KeyFields := CDS.FieldByName('KeyFields').AsString;
      DSCfg.PageSize := CDS.FieldByName('PageSize').AsInteger;

      Result.Add(DSCfg);
      CDS.Next;
    end;
  finally
    CDS.Free;
  end;
end;

function TConfigLoader.LoadGridColumns(ADatasetConfigID: Integer): TList<TGridColumnConfig>;
begin
  Result := TList<TGridColumnConfig>.Create;
end;

function TConfigLoader.LoadPanelControls(AModuleID: Integer): TList<TPanelControlConfig>;
begin
  Result := TList<TPanelControlConfig>.Create;
end;

function TConfigLoader.LoadLookups: TList<TLookupConfig>;
begin
  Result := TList<TLookupConfig>.Create;
end;

function TConfigLoader.LoadButtons(AModuleID: Integer): TList<TButtonConfig>;
begin
  Result := TList<TButtonConfig>.Create;
end;

end.
