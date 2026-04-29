unit ufrmmultitable;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ActnList, Vcl.ToolWin, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Datasnap.DBClient,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils,
  utcpclient, uappclientdataset, upermissionmgr, ulanguagemgr, uconfigmanager,
  ufrmbase;

type
  TFrmMultiTable = class(TFrmBase)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    sbMain: TStatusBar;
    Splitter1: TSplitter;
    grdMaster: TcxGrid;
    grdMasterView: TcxGridDBTableView;
    grdMasterLevel: TcxGridLevel;
    pcDetail: TPageControl;
    tsDetail1: TTabSheet;
    tsDetail2: TTabSheet;
    tsDetail3: TTabSheet;
    grdDetail1: TcxGrid;
    grdDetail1View: TcxGridDBTableView;
    grdDetail1Level: TcxGridLevel;
    grdDetail2: TcxGrid;
    grdDetail2View: TcxGridDBTableView;
    grdDetail2Level: TcxGridLevel;
    grdDetail3: TcxGrid;
    grdDetail3View: TcxGridDBTableView;
    grdDetail3Level: TcxGridLevel;
    alActions: TActionList;
    actAddMaster: TAction;
    actEditMaster: TAction;
    actDeleteMaster: TAction;
    actAddDetail: TAction;
    actEditDetail: TAction;
    actDeleteDetail: TAction;
    actRefresh: TAction;
    actSearch: TAction;
    actExport: TAction;
    actImport: TAction;
    actPrint: TAction;
    actCopy: TAction;
    actBatchDelete: TAction;
    tbActions: TToolBar;
    btnAddMaster: TToolButton;
    btnEditMaster: TToolButton;
    btnDeleteMaster: TToolButton;
    btnSep1: TToolButton;
    btnAddDetail: TToolButton;
    btnEditDetail: TToolButton;
    btnDeleteDetail: TToolButton;
    btnSep2: TToolButton;
    btnRefresh: TToolButton;
    btnSearch: TToolButton;
    btnExport: TToolButton;
    btnImport: TToolButton;
    btnPrint: TToolButton;
    btnCopy: TToolButton;
    btnBatchDelete: TToolButton;
    btnClose: TToolButton;
    dtsMaster: TDataSource;
    dtsDetail1: TDataSource;
    dtsDetail2: TDataSource;
    dtsDetail3: TDataSource;
    cdsMaster: TAppClientDataSet;
    cdsDetail1: TAppClientDataSet;
    cdsDetail2: TAppClientDataSet;
    cdsDetail3: TAppClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cdsMasterAfterScroll(DataSet: TDataSet);
    procedure actAddMasterExecute(Sender: TObject);
    procedure actEditMasterExecute(Sender: TObject);
    procedure actDeleteMasterExecute(Sender: TObject);
    procedure actAddDetailExecute(Sender: TObject);
    procedure actEditDetailExecute(Sender: TObject);
    procedure actDeleteDetailExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actBatchDeleteExecute(Sender: TObject);
    procedure pcDetailChange(Sender: TObject);
  private
    FCurrentDetailCDS: TAppClientDataSet;
    FCurrentDetailView: TcxGridDBTableView;
    procedure UpdateDetailTabs;
    function GetCurrentDetailCDS: TAppClientDataSet;
    function GetCurrentDetailView: TcxGridDBTableView;
    procedure OpenDetail(const ACDS: TAppClientDataSet; const AView: TcxGridDBTableView);
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
    procedure DoLoadConfig; override;

    procedure OpenData; virtual;
    procedure RefreshMasterOnly; virtual;
    procedure SetMasterDetailLink; virtual;
    procedure DoAddMaster; virtual;
    procedure DoEditMaster; virtual;
    procedure DoDeleteMaster; virtual;
    procedure DoAddDetail; virtual;
    procedure DoEditDetail; virtual;
    procedure DoDeleteDetail; virtual;
    procedure DoExportExcel; virtual;
    procedure DoImportExcel; virtual;
    procedure DoPrint; virtual;
  public
    property MasterCDS: TAppClientDataSet read cdsMaster;
    property Detail1CDS: TAppClientDataSet read cdsDetail1;
    property Detail2CDS: TAppClientDataSet read cdsDetail2;
    property Detail3CDS: TAppClientDataSet read cdsDetail3;
  end;

implementation

{$R *.dfm}

procedure TFrmMultiTable.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;

  cdsMaster.AssignTCPClient(FTCPClient);
  cdsDetail1.AssignTCPClient(FTCPClient);
  cdsDetail2.AssignTCPClient(FTCPClient);
  cdsDetail3.AssignTCPClient(FTCPClient);

  dtsMaster.DataSet := cdsMaster;
  dtsDetail1.DataSet := cdsDetail1;
  dtsDetail2.DataSet := cdsDetail2;
  dtsDetail3.DataSet := cdsDetail3;

  // hide tabs without detail data
  tsDetail2.TabVisible := False;
  tsDetail3.TabVisible := False;

  pcDetail.ActivePageIndex := 0;
  FCurrentDetailCDS := cdsDetail1;
  FCurrentDetailView := grdDetail1View;

  inherited;
end;

procedure TFrmMultiTable.DoCreate;
begin
  inherited;
  DoLoadConfig;
  DoApplyPermissions;
  OpenData;
  SetMasterDetailLink;
end;

procedure TFrmMultiTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if cdsMaster.ChangeCount > 0 then
    cdsMaster.ApplyUpdates(0);
  if cdsDetail1.ChangeCount > 0 then
    cdsDetail1.ApplyUpdates(0);
  if cdsDetail2.ChangeCount > 0 then
    cdsDetail2.ApplyUpdates(0);
  if cdsDetail3.ChangeCount > 0 then
    cdsDetail3.ApplyUpdates(0);
  Action := caFree;
end;

procedure TFrmMultiTable.DoApplyPermissions;
var
  BaseCode: string;
begin
  inherited;

  BaseCode := StringReplace(ClassName, 'TFrm', '', []);
  BaseCode := StringReplace(BaseCode, 'TForm', '', []);

  if Assigned(FPermissionMgr) then
  begin
    actAddMaster.Visible := FPermissionMgr.HasPermission(BaseCode + '.Add');
    actEditMaster.Visible := FPermissionMgr.HasPermission(BaseCode + '.Edit');
    actDeleteMaster.Visible := FPermissionMgr.HasPermission(BaseCode + '.Delete');
    actAddDetail.Visible := FPermissionMgr.HasPermission(BaseCode + '.AddDetail');
    actEditDetail.Visible := FPermissionMgr.HasPermission(BaseCode + '.EditDetail');
    actDeleteDetail.Visible := FPermissionMgr.HasPermission(BaseCode + '.DeleteDetail');
    actExport.Visible := FPermissionMgr.HasPermission(BaseCode + '.Export');
    actImport.Visible := FPermissionMgr.HasPermission(BaseCode + '.Import');
    actPrint.Visible := FPermissionMgr.HasPermission(BaseCode + '.Print');
    actCopy.Visible := FPermissionMgr.HasPermission(BaseCode + '.Copy');
    actBatchDelete.Visible := FPermissionMgr.HasPermission(BaseCode + '.BatchDelete');
  end;
end;

procedure TFrmMultiTable.DoLoadConfig;
begin
  inherited;
end;

procedure TFrmMultiTable.OpenData;
begin
  if cdsMaster.SQLText = '' then Exit;
  cdsMaster.OpenData(cdsMaster.SQLText);
end;

procedure TFrmMultiTable.SetMasterDetailLink;
begin
end;

procedure TFrmMultiTable.RefreshMasterOnly;
begin
  if cdsMaster.SQLText <> '' then
    cdsMaster.OpenData(cdsMaster.SQLText);
end;

procedure TFrmMultiTable.cdsMasterAfterScroll(DataSet: TDataSet);
begin
  OpenDetail(cdsDetail1, grdDetail1View);
  if tsDetail2.TabVisible then
    OpenDetail(cdsDetail2, grdDetail2View);
  if tsDetail3.TabVisible then
    OpenDetail(cdsDetail3, grdDetail3View);
end;

procedure TFrmMultiTable.OpenDetail(const ACDS: TAppClientDataSet;
  const AView: TcxGridDBTableView);
begin
  if ACDS.SQLText = '' then Exit;
  ACDS.OpenData(ACDS.SQLText);
end;

procedure TFrmMultiTable.UpdateDetailTabs;
begin
end;

function TFrmMultiTable.GetCurrentDetailCDS: TAppClientDataSet;
begin
  case pcDetail.ActivePageIndex of
    0: Result := cdsDetail1;
    1: Result := cdsDetail2;
    2: Result := cdsDetail3;
  else
    Result := cdsDetail1;
  end;
end;

function TFrmMultiTable.GetCurrentDetailView: TcxGridDBTableView;
begin
  case pcDetail.ActivePageIndex of
    0: Result := grdDetail1View;
    1: Result := grdDetail2View;
    2: Result := grdDetail3View;
  else
    Result := grdDetail1View;
  end;
end;

procedure TFrmMultiTable.DoAddMaster;
begin
  cdsMaster.Append;
end;

procedure TFrmMultiTable.DoEditMaster;
begin
  cdsMaster.Edit;
end;

procedure TFrmMultiTable.DoDeleteMaster;
begin
  cdsMaster.Delete;
end;

procedure TFrmMultiTable.DoAddDetail;
begin
  FCurrentDetailCDS.Append;
end;

procedure TFrmMultiTable.DoEditDetail;
begin
  FCurrentDetailCDS.Edit;
end;

procedure TFrmMultiTable.DoDeleteDetail;
begin
  FCurrentDetailCDS.Delete;
end;

procedure TFrmMultiTable.DoExportExcel;
var
  Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter := 'Excel Files (*.xlsx)|*.xlsx';
    Dlg.DefaultExt := 'xlsx';
    Dlg.FileName := Caption + '_Export';
    if Dlg.Execute then
      cdsMaster.ExportToExcel(Dlg.FileName);
  finally
    Dlg.Free;
  end;
end;

procedure TFrmMultiTable.DoImportExcel;
begin
end;

procedure TFrmMultiTable.DoPrint;
begin
end;

procedure TFrmMultiTable.actAddMasterExecute(Sender: TObject);
begin DoAddMaster; end;

procedure TFrmMultiTable.actEditMasterExecute(Sender: TObject);
begin DoEditMaster; end;

procedure TFrmMultiTable.actDeleteMasterExecute(Sender: TObject);
begin DoDeleteMaster; end;

procedure TFrmMultiTable.actAddDetailExecute(Sender: TObject);
begin DoAddDetail; end;

procedure TFrmMultiTable.actEditDetailExecute(Sender: TObject);
begin DoEditDetail; end;

procedure TFrmMultiTable.actDeleteDetailExecute(Sender: TObject);
begin DoDeleteDetail; end;

procedure TFrmMultiTable.actRefreshExecute(Sender: TObject);
begin OpenData; end;

procedure TFrmMultiTable.actSearchExecute(Sender: TObject);
begin OpenData; end;

procedure TFrmMultiTable.actExportExecute(Sender: TObject);
begin DoExportExcel; end;

procedure TFrmMultiTable.actImportExecute(Sender: TObject);
begin DoImportExcel; end;

procedure TFrmMultiTable.actPrintExecute(Sender: TObject);
begin DoPrint; end;

procedure TFrmMultiTable.actCopyExecute(Sender: TObject);
begin end;

procedure TFrmMultiTable.actBatchDeleteExecute(Sender: TObject);
begin end;

procedure TFrmMultiTable.pcDetailChange(Sender: TObject);
begin
  FCurrentDetailCDS := GetCurrentDetailCDS;
  FCurrentDetailView := GetCurrentDetailView;
end;

end.
