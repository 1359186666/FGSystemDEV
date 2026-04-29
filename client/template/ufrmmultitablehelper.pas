unit ufrmmultitablehelper;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin,
  Data.DB, Datasnap.DBClient,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, upermissionmgr;

type
  TMultiTableHelper = class
  private
    FForm: TForm;
    FTCPClient: TTCPClient;
    FPermissionMgr: TPermissionManager;

    FpnlTop: TPanel;
    FtbActions: TToolBar;
    FpnlBottom: TPanel;
    FgrdMaster: TcxGrid;
    FgrdMasterView: TcxGridDBTableView;
    FgrdMasterLevel: TcxGridLevel;
    FSplitter: TSplitter;
    FpcDetail: TPageControl;
    FgrdDetail: TcxGrid;
    FgrdDetailView: TcxGridDBTableView;
    FgrdDetailLevel: TcxGridLevel;
    FSplitter2: TSplitter;
    FpnlDetail: TPanel;
    FsbMain: TStatusBar;

    FalActions: TActionList;
    FactAddMaster: TAction;
    FactEditMaster: TAction;
    FactDeleteMaster: TAction;
    FactRefresh: TAction;
    FactSearch: TAction;
    FactExport: TAction;
    FactAddDetail: TAction;
    FactDeleteDetail: TAction;

    FdtsMaster: TDataSource;
    FdtsDetail: TDataSource;
    FcdsMaster: TAppClientDataSet;
    FcdsDetail: TAppClientDataSet;

    procedure CreateUI;
    procedure CreateActions;
    procedure CreateToolbar;
    procedure CreateMasterGrid;
    procedure CreateDetailGrid;

    procedure actRefreshExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure cdsMasterAfterScroll(DataSet: TDataSet);

    FOnRefresh: TNotifyEvent;
    FOnSearch: TNotifyEvent;
    FOnAddMaster: TNotifyEvent;
    FOnEditMaster: TNotifyEvent;
    FOnDeleteMaster: TNotifyEvent;
    FOnAddDetail: TNotifyEvent;
    FOnDeleteDetail: TNotifyEvent;
    FOnExport: TNotifyEvent;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;

    procedure SetTCPClient(AClient: TTCPClient);
    procedure SetPermissionManager(AMgr: TPermissionManager);

    procedure ApplyPermissions;
    procedure OpenData(const AMasterSQL: string); overload;
    procedure OpenDetail(const ADetailSQL: string);
    procedure AddDetailTab(const ACaption: string);

    property MasterCDS: TAppClientDataSet read FcdsMaster;
    property DetailCDS: TAppClientDataSet read FcdsDetail;
    property MasterView: TcxGridDBTableView read FgrdMasterView;
    property DetailView: TcxGridDBTableView read FgrdDetailView;
    property DetailPanel: TPanel read FpnlDetail;
    property PageControl: TPageControl read FpcDetail;

    property OnAddMaster: TNotifyEvent read FOnAddMaster write FOnAddMaster;
    property OnEditMaster: TNotifyEvent read FOnEditMaster write FOnEditMaster;
    property OnDeleteMaster: TNotifyEvent read FOnDeleteMaster write FOnDeleteMaster;
    property OnAddDetail: TNotifyEvent read FOnAddDetail write FOnAddDetail;
    property OnDeleteDetail: TNotifyEvent read FOnDeleteDetail write FOnDeleteDetail;
    property OnRefresh: TNotifyEvent read FOnRefresh write FOnRefresh;
    property OnSearch: TNotifyEvent read FOnSearch write FOnSearch;
    property OnExport: TNotifyEvent read FOnExport write FOnExport;
  end;

implementation

constructor TMultiTableHelper.Create(AForm: TForm);
begin
  inherited Create;
  FForm := AForm;
  FcdsMaster := TAppClientDataSet.Create(nil);
  FcdsDetail := TAppClientDataSet.Create(nil);
  FdtsMaster := TDataSource.Create(nil);
  FdtsDetail := TDataSource.Create(nil);
  FdtsMaster.DataSet := FcdsMaster;
  FdtsDetail.DataSet := FcdsDetail;
  FcdsMaster.AfterScroll := cdsMasterAfterScroll;
  CreateUI;
end;

destructor TMultiTableHelper.Destroy;
begin
  FcdsMaster.Free;
  FcdsDetail.Free;
  FdtsMaster.Free;
  FdtsDetail.Free;
  FalActions.Free;
  inherited;
end;

procedure TMultiTableHelper.SetTCPClient(AClient: TTCPClient);
begin
  FTCPClient := AClient;
  FcdsMaster.AssignTCPClient(FTCPClient);
  FcdsDetail.AssignTCPClient(FTCPClient);
end;

procedure TMultiTableHelper.SetPermissionManager(AMgr: TPermissionManager);
begin
  FPermissionMgr := AMgr;
end;

procedure TMultiTableHelper.CreateUI;
begin
  CreateActions;

  FpnlTop := TPanel.Create(FForm);
  FpnlTop.Parent := FForm;
  FpnlTop.Align := alTop;
  FpnlTop.Height := 38;
  FpnlTop.BevelOuter := bvNone;

  CreateToolbar;

  FpnlBottom := TPanel.Create(FForm);
  FpnlBottom.Parent := FForm;
  FpnlBottom.Align := alClient;
  FpnlBottom.BevelOuter := bvNone;

  CreateMasterGrid;

  FSplitter := TSplitter.Create(FForm);
  FSplitter.Parent := FpnlBottom;
  FSplitter.Align := alTop;
  FSplitter.Height := 3;

  FpcDetail := TPageControl.Create(FForm);
  FpcDetail.Parent := FpnlBottom;
  FpcDetail.Align := alClient;

  CreateDetailGrid;

  FsbMain := TStatusBar.Create(FForm);
  FsbMain.Parent := FForm;

  FForm.Height := 600;
  FForm.Width := 900;
  FForm.Position := poDefault;
end;

procedure TMultiTableHelper.CreateActions;
begin
  FalActions := TActionList.Create(FForm);

  FactAddMaster := TAction.Create(FalActions);
  FactAddMaster.Caption := STplBtnAdd;
  FactAddMaster.OnExecute := actRefreshExecute;

  FactEditMaster := TAction.Create(FalActions);
  FactEditMaster.Caption := STplBtnEdit;

  FactDeleteMaster := TAction.Create(FalActions);
  FactDeleteMaster.Caption := STplBtnDelete;

  FactRefresh := TAction.Create(FalActions);
  FactRefresh.Caption := STplBtnRefresh;
  FactRefresh.OnExecute := actRefreshExecute;

  FactSearch := TAction.Create(FalActions);
  FactSearch.Caption := STplBtnSearch;
  FactSearch.OnExecute := actSearchExecute;

  FactExport := TAction.Create(FalActions);
  FactExport.Caption := STplBtnExport;
  FactExport.OnExecute := actExportExecute;

  FactAddDetail := TAction.Create(FalActions);
  FactAddDetail.Caption := STplBtnAddDetail;

  FactDeleteDetail := TAction.Create(FalActions);
  FactDeleteDetail.Caption := STplBtnDeleteDetail;
end;

procedure TMultiTableHelper.CreateToolbar;
var
  btn: TToolButton;
begin
  FtbActions := TToolBar.Create(FForm);
  FtbActions.Parent := FpnlTop;
  FtbActions.Align := alClient;

  btn := TToolButton.Create(FtbActions); btn.Action := FactAddMaster; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactEditMaster; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactDeleteMaster; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Style := tbsSeparator; btn.Width := 8; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactAddDetail; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactDeleteDetail; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Style := tbsSeparator; btn.Width := 8; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactRefresh; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactSearch; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactExport; btn.Parent := FtbActions;
end;

procedure TMultiTableHelper.CreateMasterGrid;
begin
  FgrdMaster := TcxGrid.Create(FForm);
  FgrdMaster.Parent := FpnlBottom;
  FgrdMaster.Align := alTop;
  FgrdMaster.Height := 250;

  FgrdMasterView := TcxGridDBTableView.Create(FgrdMaster);
  FgrdMasterView.DataController.DataSource := FdtsMaster;
  FgrdMasterView.OptionsSelection.CellSelect := False;
  FgrdMasterView.OptionsView.GroupByBox := False;

  FgrdMasterLevel := TcxGridLevel.Create(FgrdMaster);
  FgrdMasterLevel.GridView := FgrdMasterView;
end;

procedure TMultiTableHelper.CreateDetailGrid;
var
  ts: TTabSheet;
begin
  ts := TTabSheet.Create(FForm);
  ts.PageControl := FpcDetail;
  ts.Caption := 'Detail';

  FgrdDetail := TcxGrid.Create(FForm);
  FgrdDetail.Parent := ts;
  FgrdDetail.Align := alClient;

  FgrdDetailView := TcxGridDBTableView.Create(FgrdDetail);
  FgrdDetailView.DataController.DataSource := FdtsDetail;
  FgrdDetailView.OptionsSelection.CellSelect := False;
  FgrdDetailView.OptionsView.GroupByBox := False;

  FgrdDetailLevel := TcxGridLevel.Create(FgrdDetail);
  FgrdDetailLevel.GridView := FgrdDetailView;
end;

procedure TMultiTableHelper.OpenData(const AMasterSQL: string);
begin
  FcdsMaster.SQLText := AMasterSQL;
  FcdsMaster.PageIndex := 1;
  FcdsMaster.OpenData(AMasterSQL);
end;

procedure TMultiTableHelper.OpenDetail(const ADetailSQL: string);
begin
  FcdsDetail.SQLText := ADetailSQL;
  FcdsDetail.OpenData(ADetailSQL);
end;

procedure TMultiTableHelper.AddDetailTab(const ACaption: string);
var
  ts: TTabSheet;
begin
  ts := TTabSheet.Create(FForm);
  ts.PageControl := FpcDetail;
  ts.Caption := ACaption;
end;

procedure TMultiTableHelper.ApplyPermissions;
begin
  if FPermissionMgr = nil then Exit;
  FactAddMaster.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Add');
  FactEditMaster.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Edit');
  FactDeleteMaster.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Delete');
  FactExport.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Export');
end;

procedure TMultiTableHelper.actRefreshExecute(Sender: TObject);
begin if Assigned(FOnRefresh) then FOnRefresh(Sender); end;

procedure TMultiTableHelper.actSearchExecute(Sender: TObject);
begin if Assigned(FOnSearch) then FOnSearch(Sender); end;

procedure TMultiTableHelper.actExportExecute(Sender: TObject);
begin if Assigned(FOnExport) then FOnExport(Sender); end;

procedure TMultiTableHelper.cdsMasterAfterScroll(DataSet: TDataSet);
begin
  if Assigned(FOnAddDetail) then
    FOnAddDetail(nil);
end;

end.
