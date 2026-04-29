unit uconfigmanager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.ComCtrls,
  Data.DB,
  uapptypes, uappdefines, uapputils, uappclientdataset, utcpclient, uconfigtypes, uconfigloader;

type
  TConfigManager = class
  private
    FTCPClient: TTCPClient;
    FConfigLoader: TConfigLoader;
  public
    constructor Create(ATCPClient: TTCPClient);
    destructor Destroy; override;

    function HasConfig(const AModuleName: string): Boolean;
    function GetModuleConfig(const AModuleName: string): TModuleConfigData;
    procedure RefreshCache;

    // Apply config to form at runtime
    procedure BuildFormFromConfig(AForm: TForm; AConfig: TModuleConfigData);

    // Save config back
    function SaveModuleConfig(AConfig: TModuleConfigData): Boolean;
    function SaveDataSetConfig(const ACfg: TDataSetConfig): Boolean;
    function SaveGridColumnConfig(const ACfg: TGridColumnConfig): Boolean;
    function SavePanelControlConfig(const ACfg: TPanelControlConfig): Boolean;
    function SaveLookupConfig(const ACfg: TLookupConfig): Boolean;
    function SaveButtonConfig(const ACfg: TButtonConfig): Boolean;

    // Delete configs
    function DeleteModuleConfig(AModuleID: Integer): Boolean;
    function DeleteDataSetConfig(AID: Integer): Boolean;
    function DeleteGridColumnConfig(AID: Integer): Boolean;
    function DeletePanelControlConfig(AID: Integer): Boolean;
    function DeleteLookupConfig(AID: Integer): Boolean;
    function DeleteButtonConfig(AID: Integer): Boolean;
  end;

implementation

constructor TConfigManager.Create(ATCPClient: TTCPClient);
begin
  inherited Create;
  FTCPClient := ATCPClient;
  FConfigLoader := TConfigLoader.Create(ATCPClient);
end;

destructor TConfigManager.Destroy;
begin
  FConfigLoader.Free;
  inherited;
end;

function TConfigManager.HasConfig(const AModuleName: string): Boolean;
var
  MCD: TModuleConfigData;
begin
  MCD := FConfigLoader.LoadModuleConfig(AModuleName);
  Result := MCD.Module.ID > 0;
end;

procedure TConfigManager.RefreshCache;
begin
  FConfigLoader.RefreshCache;
end;

function TConfigManager.GetModuleConfig(const AModuleName: string): TModuleConfigData;
begin
  Result := FConfigLoader.LoadModuleConfig(AModuleName);
end;

procedure TConfigManager.BuildFormFromConfig(AForm: TForm;
  AConfig: TModuleConfigData);
begin
  if AConfig.Module.ID = 0 then Exit;

  // dataset setup - assign SQL to cdsMaster etc.
  // grid column config - build cxGrid columns
  // panel controls - create DBEdit etc.
  // button config - set button visibility/caption
end;

function TConfigManager.SaveModuleConfig(AConfig: TModuleConfigData): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);

    if AConfig.Module.ID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_ModuleConfig ' +
        '(ModuleName, ModuleCaption, ModuleCode, ParentMenuName, ' +
        'MenuIconIndex, SortOrder, IsActive) ' +
        'VALUES (''%s'', ''%s'', ''%s'', ''%s'', %d, %d, 1)',
        [AConfig.Module.ModuleName,
         AConfig.Module.ModuleCaption,
         AConfig.Module.ModuleCode,
         AConfig.Module.ParentMenuName,
         AConfig.Module.MenuIconIndex,
         AConfig.Module.SortOrder]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_ModuleConfig SET ' +
        'ModuleCaption = ''%s'', ParentMenuName = ''%s'', ' +
        'MenuIconIndex = %d, SortOrder = %d, IsActive = %d ' +
        'WHERE ID = %d',
        [AConfig.Module.ModuleCaption,
         AConfig.Module.ParentMenuName,
         AConfig.Module.MenuIconIndex,
         AConfig.Module.SortOrder,
         Ord(AConfig.Module.IsActive),
         AConfig.Module.ID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.SaveDataSetConfig(const ACfg: TDataSetConfig): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    if ACfg.ID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_DataSetConfig ' +
        '(ModuleID, DatasetName, SQLText, KeyFields, DefaultOrderBy, ' +
        'PageSize, IsReadOnly, MasterDatasetName, MasterKeyFields) ' +
        'VALUES (%d, ''%s'', ''%s'', ''%s'', ''%s'', %d, %d, ''%s'', ''%s'')',
        [ACfg.ModuleID,
         ACfg.DatasetName,
         StringReplace(ACfg.SQLText, '''', '''''', [rfReplaceAll]),
         ACfg.KeyFields,
         ACfg.DefaultOrderBy,
         ACfg.PageSize,
         Ord(ACfg.IsReadOnly),
         ACfg.MasterDatasetName,
         ACfg.MasterKeyFields]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_DataSetConfig SET ' +
        'SQLText = ''%s'', KeyFields = ''%s'', DefaultOrderBy = ''%s'', ' +
        'PageSize = %d, IsReadOnly = %d ' +
        'WHERE ID = %d',
        [StringReplace(ACfg.SQLText, '''', '''''', [rfReplaceAll]),
         ACfg.KeyFields,
         ACfg.DefaultOrderBy,
         ACfg.PageSize,
         Ord(ACfg.IsReadOnly),
         ACfg.ID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.SaveGridColumnConfig(const ACfg: TGridColumnConfig): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    if ACfg.ID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_GridColumnConfig ' +
        '(DatasetConfigID, FieldName, ColumnCaption, ColumnIndex, ColumnWidth, ' +
        'Visible, ReadOnly, Alignment, DisplayFormat, IsLookup, ' +
        'LookupDatasetID, LookupKeyField, LookupDisplayField) ' +
        'VALUES (%d, ''%s'', ''%s'', %d, %d, %d, %d, ''%s'', ''%s'', %d, %d, ''%s'', ''%s'')',
        [ACfg.DatasetConfigID,
         ACfg.FieldName, ACfg.ColumnCaption,
         ACfg.ColumnIndex, ACfg.ColumnWidth,
         Ord(ACfg.Visible), Ord(ACfg.ReadOnly),
         ACfg.Alignment, ACfg.DisplayFormat,
         Ord(ACfg.IsLookup), ACfg.LookupDatasetID,
         ACfg.LookupKeyField, ACfg.LookupDisplayField]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_GridColumnConfig SET ' +
        'FieldName = ''%s'', ColumnCaption = ''%s'', ColumnIndex = %d, ' +
        'ColumnWidth = %d, Visible = %d, ReadOnly = %d, ' +
        'Alignment = ''%s'', DisplayFormat = ''%s'', IsLookup = %d ' +
        'WHERE ID = %d',
        [ACfg.FieldName, ACfg.ColumnCaption, ACfg.ColumnIndex,
         ACfg.ColumnWidth, Ord(ACfg.Visible), Ord(ACfg.ReadOnly),
         ACfg.Alignment, ACfg.DisplayFormat, Ord(ACfg.IsLookup), ACfg.ID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.SavePanelControlConfig(const ACfg: TPanelControlConfig): Boolean;
var
  CDS: TAppClientDataSet;
  CtrlTypeStr: string;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CtrlTypeStr := ControlTypeToString(ACfg.ControlType);
    if ACfg.ID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_PanelControlConfig ' +
        '(ModuleID, DatasetName, PanelName, FieldName, ControlType, ' +
        'Caption, [Left], [Top], Width, Height, TabOrder, ReadOnly, Required, ' +
        'LookupDatasetID, LookupKeyField, LookupDisplayField, Visible) ' +
        'VALUES (%d, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %d, %d, %d, %d, %d, %d, %d, %d, ''%s'', ''%s'', %d)',
        [ACfg.ModuleID, ACfg.DatasetName, ACfg.PanelName,
         ACfg.FieldName, CtrlTypeStr, ACfg.Caption,
         ACfg.Left, ACfg.Top, ACfg.Width, ACfg.Height,
         ACfg.TabOrder, Ord(ACfg.ReadOnly), Ord(ACfg.Required),
         ACfg.LookupDatasetID,
         ACfg.LookupKeyField, ACfg.LookupDisplayField,
         Ord(ACfg.Visible)]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_PanelControlConfig SET ' +
        'Caption = ''%s'', [Left] = %d, [Top] = %d, Width = %d, Height = %d, ' +
        'TabOrder = %d, ReadOnly = %d, Required = %d, Visible = %d ' +
        'WHERE ID = %d',
        [ACfg.Caption, ACfg.Left, ACfg.Top, ACfg.Width, ACfg.Height,
         ACfg.TabOrder, Ord(ACfg.ReadOnly), Ord(ACfg.Required),
         Ord(ACfg.Visible), ACfg.ID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.SaveLookupConfig(const ACfg: TLookupConfig): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    if ACfg.ID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_LookupConfig ' +
        '(LookupName, LookupCaption, SQLText, KeyField, DisplayField, ListFields, IsTreeData) ' +
        'VALUES (''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %d)',
        [ACfg.LookupName, ACfg.LookupCaption,
         StringReplace(ACfg.SQLText, '''', '''''', [rfReplaceAll]),
         ACfg.KeyField, ACfg.DisplayField, ACfg.ListFields,
         Ord(ACfg.IsTreeData)]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_LookupConfig SET ' +
        'LookupCaption = ''%s'', SQLText = ''%s'', KeyField = ''%s'', ' +
        'DisplayField = ''%s'', ListFields = ''%s'' ' +
        'WHERE ID = %d',
        [ACfg.LookupCaption,
         StringReplace(ACfg.SQLText, '''', '''''', [rfReplaceAll]),
         ACfg.KeyField, ACfg.DisplayField, ACfg.ListFields, ACfg.ID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.SaveButtonConfig(const ACfg: TButtonConfig): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    if ACfg.ID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_ButtonConfig ' +
        '(ModuleID, ButtonName, ButtonCaption, ActionType, ToolbarGroup, ' +
        'ImageIndex, ShortCut, Hint) ' +
        'VALUES (%d, ''%s'', ''%s'', ''%s'', ''%s'', %d, ''%s'', ''%s'')',
        [ACfg.ModuleID, ACfg.ButtonName, ACfg.ButtonCaption,
         ACfg.ActionType, ACfg.ToolbarGroup,
         ACfg.ImageIndex, ACfg.ShortCut, ACfg.Hint]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_ButtonConfig SET ' +
        'ButtonCaption = ''%s'', ActionType = ''%s'', ToolbarGroup = ''%s'' ' +
        'WHERE ID = %d',
        [ACfg.ButtonCaption, ACfg.ActionType, ACfg.ToolbarGroup, ACfg.ID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.DeleteModuleConfig(AModuleID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_GridColumnConfig WHERE DatasetConfigID IN (SELECT ID FROM sys_DataSetConfig WHERE ModuleID = %d)', [AModuleID]));
    CDS.ExecCommand(Format('DELETE FROM sys_DataSetConfig WHERE ModuleID = %d', [AModuleID]));
    CDS.ExecCommand(Format('DELETE FROM sys_PanelControlConfig WHERE ModuleID = %d', [AModuleID]));
    CDS.ExecCommand(Format('DELETE FROM sys_ButtonConfig WHERE ModuleID = %d', [AModuleID]));
    CDS.ExecCommand(Format('DELETE FROM sys_ModuleConfig WHERE ID = %d', [AModuleID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.DeleteDataSetConfig(AID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_GridColumnConfig WHERE DatasetConfigID = %d', [AID]));
    CDS.ExecCommand(Format('DELETE FROM sys_DataSetConfig WHERE ID = %d', [AID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.DeleteGridColumnConfig(AID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_GridColumnConfig WHERE ID = %d', [AID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.DeletePanelControlConfig(AID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_PanelControlConfig WHERE ID = %d', [AID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.DeleteLookupConfig(AID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_LookupConfig WHERE ID = %d', [AID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TConfigManager.DeleteButtonConfig(AID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_ButtonConfig WHERE ID = %d', [AID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

end.
