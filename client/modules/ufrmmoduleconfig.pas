unit ufrmmoduleconfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, uconfigmanager, uconfigtypes,
  ufrmbase, ufrmsingletable;

type
  TModuleConfigFrm = class(TFrmSingleTable)
    tsModule: TTabSheet;
    tsDataSet: TTabSheet;
    tsGridColumns: TTabSheet;
    tsPanelControls: TTabSheet;
    tsButtons: TTabSheet;
    pcConfig: TPageControl;
    actSaveConfig: TAction;
    actRefreshPerm: TAction;
    actPreviewModule: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actSaveConfigExecute(Sender: TObject);
    procedure actRefreshPermExecute(Sender: TObject);
    procedure actPreviewModuleExecute(Sender: TObject);
  private
    procedure LoadModuleList;
    procedure LoadDataSetConfig;
    procedure LoadGridColumnConfig;
    procedure LoadPanelControlConfig;
    procedure LoadButtonConfig;
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
  end;

implementation

{$R *.dfm}

procedure TModuleConfigFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  pcConfig := TPageControl.Create(Self);
  pcConfig.Parent := pnlDetail;
  pcConfig.Align := alClient;

  tsModule := TTabSheet.Create(Self);
  tsModule.PageControl := pcConfig;
  tsModule.Caption := 'Module Info';

  tsDataSet := TTabSheet.Create(Self);
  tsDataSet.PageControl := pcConfig;
  tsDataSet.Caption := 'Datasets';

  tsGridColumns := TTabSheet.Create(Self);
  tsGridColumns.PageControl := pcConfig;
  tsGridColumns.Caption := 'Grid Columns';

  tsPanelControls := TTabSheet.Create(Self);
  tsPanelControls.PageControl := pcConfig;
  tsPanelControls.Caption := 'Panel Controls';

  tsButtons := TTabSheet.Create(Self);
  tsButtons.PageControl := pcConfig;
  tsButtons.Caption := 'Buttons';

  inherited;
end;

procedure TModuleConfigFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_ModuleConfig';
  cdsMaster.KeyFields := 'ID';
  cdsMaster.SQLText := 'SELECT * FROM sys_ModuleConfig ORDER BY SortOrder, ModuleCode';
  inherited;
end;

procedure TModuleConfigFrm.DoApplyPermissions;
begin
  inherited;
  actSaveConfig.Visible := True;
  actRefreshPerm.Visible := True;
  actPreviewModule.Visible := True;
end;

procedure TModuleConfigFrm.LoadModuleList;
begin
  OpenData;
end;

procedure TModuleConfigFrm.LoadDataSetConfig;
begin
end;

procedure TModuleConfigFrm.LoadGridColumnConfig;
begin
end;

procedure TModuleConfigFrm.LoadPanelControlConfig;
begin
end;

procedure TModuleConfigFrm.LoadButtonConfig;
begin
end;

procedure TModuleConfigFrm.actSaveConfigExecute(Sender: TObject);
var
  Cfg: TModuleConfigData;
  M: TModuleConfig;
begin
  Cfg := FConfigManager.GetModuleConfig(cdsMaster.FieldByName('ModuleName').AsString);
  M := Cfg.Module;
  M.ModuleName := cdsMaster.FieldByName('ModuleName').AsString;
  M.ModuleCaption := cdsMaster.FieldByName('ModuleCaption').AsString;
  M.ModuleCode := cdsMaster.FieldByName('ModuleCode').AsString;
  M.ParentMenuName := cdsMaster.FieldByName('ParentMenuName').AsString;
  M.MenuIconIndex := cdsMaster.FieldByName('MenuIconIndex').AsInteger;
  M.SortOrder := cdsMaster.FieldByName('SortOrder').AsInteger;
  Cfg.Module := M;

  if FConfigManager.SaveModuleConfig(Cfg) then
    Application.MessageBox(PChar(SConfigMsgSaveSuccess), PChar(Caption),
      MB_OK or MB_ICONINFORMATION);
end;

procedure TModuleConfigFrm.actRefreshPermExecute(Sender: TObject);
begin
  if FPermissionMgr <> nil then
    FPermissionMgr.RefreshModulePermissions(Self);
  Application.MessageBox(PChar(SPermMsgRefreshOK), PChar(Caption),
    MB_OK or MB_ICONINFORMATION);
end;

procedure TModuleConfigFrm.actPreviewModuleExecute(Sender: TObject);
begin
end;

end.
