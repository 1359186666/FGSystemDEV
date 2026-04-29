unit ufrmsingletablehelper;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin,
  Data.DB, Datasnap.DBClient,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, upermissionmgr, ulanguagemgr, uconfigmanager;

type
  TSingleTableHelper = class
  private
    FForm: TForm;
    FTCPClient: TTCPClient;
    FPermissionMgr: TPermissionManager;
    FLanguageManager: TLanguageManager;

    FpnlTop: TPanel;
    FtbActions: TToolBar;
    FpnlBottom: TPanel;
    FgrdMain: TcxGrid;
    FgrdMainView: TcxGridDBTableView;
    FgrdMainLevel: TcxGridLevel;
    FSplitter: TSplitter;
    FpnlDetail: TPanel;
    FgbxSearch: TGroupBox;
    FsbMain: TStatusBar;

    FalActions: TActionList;
    FactAdd: TAction;
    FactEdit: TAction;
    FactDelete: TAction;
    FactRefresh: TAction;
    FactSearch: TAction;
    FactReset: TAction;
    FactExport: TAction;
    FactImport: TAction;
    FactPrint: TAction;
    FactCopy: TAction;
    FactBatchDelete: TAction;
    FactBatchAudit: TAction;
    FactFirst: TAction;
    FactPrior: TAction;
    FactNext: TAction;
    FactLast: TAction;

    FdtsMain: TDataSource;
    FcdsMaster: TAppClientDataSet;

    FOnAdd: TNotifyEvent;
    FOnEdit: TNotifyEvent;
    FOnDelete: TNotifyEvent;
    FOnRefresh: TNotifyEvent;
    FOnSearch: TNotifyEvent;
    FOnExport: TNotifyEvent;
    FOnImport: TNotifyEvent;
    FOnPrint: TNotifyEvent;
    FOnCopy: TNotifyEvent;
    FOnBatchDelete: TNotifyEvent;
    FOnBatchAudit: TNotifyEvent;
    FOnDblClickGrid: TNotifyEvent;

    procedure CreateUI;
    procedure CreateActions;
    procedure CreateToolbar;
    procedure CreateGrid;
    procedure BuildGridColumns;

    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actExportExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actCopyExecute(Sender: TObject);
    procedure actBatchDeleteExecute(Sender: TObject);
    procedure actBatchAuditExecute(Sender: TObject);
    procedure actFirstExecute(Sender: TObject);
    procedure actPriorExecute(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actLastExecute(Sender: TObject);
    procedure grdMainViewDblClick(Sender: TObject);

    procedure DoExportExcel;
    procedure DoImportExcel;
    procedure DoFirstPage;
    procedure DoPriorPage;
    procedure DoNextPage;
    procedure DoLastPage;
    procedure UpdateStatus;
  public
    constructor Create(AForm: TForm);
    destructor Destroy; override;

    procedure SetTCPClient(AClient: TTCPClient);
    procedure SetPermissionManager(AMgr: TPermissionManager);
    procedure SetLanguageManager(AMgr: TLanguageManager);

    procedure ApplyPermissions;
    procedure OpenData(const ASQL: string); overload;
    procedure OpenData(const ASQL: string; AParams: array of Variant); overload;

    property GridView: TcxGridDBTableView read FgrdMainView;
    property MasterCDS: TAppClientDataSet read FcdsMaster;
    property SearchGroupBox: TGroupBox read FgbxSearch;
    property DetailPanel: TPanel read FpnlDetail;
    property StatusBar: TStatusBar read FsbMain;

    property OnAdd: TNotifyEvent read FOnAdd write FOnAdd;
    property OnEdit: TNotifyEvent read FOnEdit write FOnEdit;
    property OnDelete: TNotifyEvent read FOnDelete write FOnDelete;
    property OnRefresh: TNotifyEvent read FOnRefresh write FOnRefresh;
    property OnSearch: TNotifyEvent read FOnSearch write FOnSearch;
    property OnExport: TNotifyEvent read FOnExport write FOnExport;
    property OnImport: TNotifyEvent read FOnImport write FOnImport;
    property OnPrint: TNotifyEvent read FOnPrint write FOnPrint;
    property OnCopy: TNotifyEvent read FOnCopy write FOnCopy;
    property OnBatchDelete: TNotifyEvent read FOnBatchDelete write FOnBatchDelete;
    property OnBatchAudit: TNotifyEvent read FOnBatchAudit write FOnBatchAudit;
    property OnDblClickGrid: TNotifyEvent read FOnDblClickGrid write FOnDblClickGrid;
  end;

implementation

constructor TSingleTableHelper.Create(AForm: TForm);
begin
  inherited Create;
  FForm := AForm;
  FcdsMaster := TAppClientDataSet.Create(nil);
  FdtsMain := TDataSource.Create(nil);
  FdtsMain.DataSet := FcdsMaster;
  CreateUI;
end;

destructor TSingleTableHelper.Destroy;
begin
  FcdsMaster.Free;
  FdtsMain.Free;
  FalActions.Free;
  inherited;
end;

procedure TSingleTableHelper.SetTCPClient(AClient: TTCPClient);
begin
  FTCPClient := AClient;
  FcdsMaster.AssignTCPClient(FTCPClient);
end;

procedure TSingleTableHelper.SetPermissionManager(AMgr: TPermissionManager);
begin
  FPermissionMgr := AMgr;
end;

procedure TSingleTableHelper.SetLanguageManager(AMgr: TLanguageManager);
begin
  FLanguageManager := AMgr;
end;

procedure TSingleTableHelper.CreateUI;
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

  CreateGrid;

  FSplitter := TSplitter.Create(FForm);
  FSplitter.Parent := FpnlBottom;
  FSplitter.Align := alBottom;
  FSplitter.Height := 3;

  FpnlDetail := TPanel.Create(FForm);
  FpnlDetail.Parent := FpnlBottom;
  FpnlDetail.Align := alBottom;
  FpnlDetail.Height := 200;
  FpnlDetail.BevelOuter := bvNone;

  FgbxSearch := TGroupBox.Create(FForm);
  FgbxSearch.Parent := FpnlDetail;
  FgbxSearch.Left := 8;
  FgbxSearch.Top := 8;
  FgbxSearch.Width := 400;
  FgbxSearch.Height := 60;
  FgbxSearch.Caption := 'Search';

  FsbMain := TStatusBar.Create(FForm);
  FsbMain.Parent := FForm;

  FForm.Height := 600;
  FForm.Width := 900;
  FForm.Position := poDefault;
end;

procedure TSingleTableHelper.CreateActions;
begin
  FalActions := TActionList.Create(FForm);

  FactAdd := TAction.Create(FalActions);
  FactAdd.ActionList := FalActions;
  FactAdd.Caption := STplBtnAdd;
  FactAdd.OnExecute := actAddExecute;

  FactEdit := TAction.Create(FalActions);
  FactEdit.ActionList := FalActions;
  FactEdit.Caption := STplBtnEdit;
  FactEdit.OnExecute := actEditExecute;

  FactDelete := TAction.Create(FalActions);
  FactDelete.ActionList := FalActions;
  FactDelete.Caption := STplBtnDelete;
  FactDelete.OnExecute := actDeleteExecute;

  FactRefresh := TAction.Create(FalActions);
  FactRefresh.ActionList := FalActions;
  FactRefresh.Caption := STplBtnRefresh;
  FactRefresh.OnExecute := actRefreshExecute;

  FactSearch := TAction.Create(FalActions);
  FactSearch.ActionList := FalActions;
  FactSearch.Caption := STplBtnSearch;
  FactSearch.OnExecute := actSearchExecute;

  FactReset := TAction.Create(FalActions);
  FactReset.ActionList := FalActions;
  FactReset.Caption := STplBtnReset;
  FactReset.OnExecute := actResetExecute;

  FactExport := TAction.Create(FalActions);
  FactExport.ActionList := FalActions;
  FactExport.Caption := STplBtnExport;
  FactExport.OnExecute := actExportExecute;

  FactImport := TAction.Create(FalActions);
  FactImport.ActionList := FalActions;
  FactImport.Caption := STplBtnImport;
  FactImport.OnExecute := actImportExecute;

  FactPrint := TAction.Create(FalActions);
  FactPrint.ActionList := FalActions;
  FactPrint.Caption := STplBtnPrint;
  FactPrint.OnExecute := actPrintExecute;

  FactCopy := TAction.Create(FalActions);
  FactCopy.ActionList := FalActions;
  FactCopy.Caption := STplBtnCopy;
  FactCopy.OnExecute := actCopyExecute;

  FactBatchDelete := TAction.Create(FalActions);
  FactBatchDelete.ActionList := FalActions;
  FactBatchDelete.Caption := STplBtnBatchDelete;
  FactBatchDelete.OnExecute := actBatchDeleteExecute;

  FactBatchAudit := TAction.Create(FalActions);
  FactBatchAudit.ActionList := FalActions;
  FactBatchAudit.Caption := STplBtnBatchAudit;
  FactBatchAudit.OnExecute := actBatchAuditExecute;

  FactFirst := TAction.Create(FalActions);
  FactFirst.ActionList := FalActions;
  FactFirst.Caption := STplBtnFirst;
  FactFirst.OnExecute := actFirstExecute;

  FactPrior := TAction.Create(FalActions);
  FactPrior.ActionList := FalActions;
  FactPrior.Caption := STplBtnPrior;
  FactPrior.OnExecute := actPriorExecute;

  FactNext := TAction.Create(FalActions);
  FactNext.ActionList := FalActions;
  FactNext.Caption := STplBtnNext;
  FactNext.OnExecute := actNextExecute;

  FactLast := TAction.Create(FalActions);
  FactLast.ActionList := FalActions;
  FactLast.Caption := STplBtnLast;
  FactLast.OnExecute := actLastExecute;
end;

procedure TSingleTableHelper.CreateToolbar;
var
  btn: TToolButton;
begin
  FtbActions := TToolBar.Create(FForm);
  FtbActions.Parent := FpnlTop;
  FtbActions.Align := alClient;

  btn := TToolButton.Create(FtbActions); btn.Action := FactAdd; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactEdit; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactDelete; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactRefresh; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactSearch; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactExport; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactImport; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactPrint; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactCopy; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactBatchDelete; btn.Parent := FtbActions;
  btn := TToolButton.Create(FtbActions); btn.Action := FactBatchAudit; btn.Parent := FtbActions;
end;

procedure TSingleTableHelper.CreateGrid;
begin
  FgrdMain := TcxGrid.Create(FForm);
  FgrdMain.Parent := FpnlBottom;
  FgrdMain.Align := alClient;
  FgrdMain.TabOrder := 0;

  FgrdMainView := TcxGridDBTableView.Create(FgrdMain);
  FgrdMainView.DataController.DataSource := FdtsMain;
  FgrdMainView.OptionsSelection.CellSelect := False;
  FgrdMainView.OptionsView.GroupByBox := False;
  FgrdMainView.OnDblClick := grdMainViewDblClick;

  FgrdMainLevel := TcxGridLevel.Create(FgrdMain);
  FgrdMainLevel.GridView := FgrdMainView;
end;

procedure TSingleTableHelper.BuildGridColumns;
var
  I: Integer;
  Col: TcxGridDBColumn;
begin
  FgrdMainView.BeginUpdate;
  try
    FgrdMainView.ClearItems;
    for I := 0 to FcdsMaster.Fields.Count - 1 do
    begin
      if not FcdsMaster.Fields[I].Visible then Continue;
      Col := FgrdMainView.CreateColumn;
      Col.DataBinding.FieldName := FcdsMaster.Fields[I].FieldName;
      Col.Caption := FcdsMaster.Fields[I].DisplayLabel;
      Col.Width := FcdsMaster.Fields[I].DisplayWidth;
      if Col.Width < 50 then Col.Width := 80;
    end;
  finally
    FgrdMainView.EndUpdate;
  end;
end;

procedure TSingleTableHelper.OpenData(const ASQL: string);
begin
  FcdsMaster.SQLText := ASQL;
  FcdsMaster.PageIndex := 1;
  FcdsMaster.OpenData(ASQL);
  BuildGridColumns;
  UpdateStatus;
end;

procedure TSingleTableHelper.OpenData(const ASQL: string; AParams: array of Variant);
begin
  FcdsMaster.Params.Clear;
  FcdsMaster.OpenData(ASQL, AParams);
  BuildGridColumns;
  UpdateStatus;
end;

procedure TSingleTableHelper.UpdateStatus;
begin
  if FcdsMaster.TotalCount > 0 then
    FsbMain.Panels.Add;
    FsbMain.Panels[0].Text := Format(STplStatusRecordCount, [FcdsMaster.TotalCount]);
end;

procedure TSingleTableHelper.ApplyPermissions;
begin
  if FPermissionMgr = nil then Exit;
  FactAdd.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Add');
  FactEdit.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Edit');
  FactDelete.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Delete');
  FactExport.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Export');
  FactImport.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Import');
  FactPrint.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Print');
  FactCopy.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.Copy');
  FactBatchDelete.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.BatchDelete');
  FactBatchAudit.Visible := FPermissionMgr.HasPermission(FForm.ClassName + '.BatchAudit');
end;

procedure TSingleTableHelper.actAddExecute(Sender: TObject);
begin if Assigned(FOnAdd) then FOnAdd(Sender); end;
procedure TSingleTableHelper.actEditExecute(Sender: TObject);
begin if Assigned(FOnEdit) then FOnEdit(Sender); end;
procedure TSingleTableHelper.actDeleteExecute(Sender: TObject);
begin if Assigned(FOnDelete) then FOnDelete(Sender); end;
procedure TSingleTableHelper.actRefreshExecute(Sender: TObject);
begin if Assigned(FOnRefresh) then FOnRefresh(Sender); end;
procedure TSingleTableHelper.actSearchExecute(Sender: TObject);
begin if Assigned(FOnSearch) then FOnSearch(Sender); end;
procedure TSingleTableHelper.actResetExecute(Sender: TObject);
begin FcdsMaster.Params.Clear; if Assigned(FOnSearch) then FOnSearch(Sender); end;
procedure TSingleTableHelper.actExportExecute(Sender: TObject);
begin if Assigned(FOnExport) then FOnExport(Sender) else DoExportExcel; end;
procedure TSingleTableHelper.actImportExecute(Sender: TObject);
begin if Assigned(FOnImport) then FOnImport(Sender) else DoImportExcel; end;
procedure TSingleTableHelper.actPrintExecute(Sender: TObject);
begin if Assigned(FOnPrint) then FOnPrint(Sender); end;
procedure TSingleTableHelper.actCopyExecute(Sender: TObject);
begin if Assigned(FOnCopy) then FOnCopy(Sender); end;
procedure TSingleTableHelper.actBatchDeleteExecute(Sender: TObject);
begin if Assigned(FOnBatchDelete) then FOnBatchDelete(Sender); end;
procedure TSingleTableHelper.actBatchAuditExecute(Sender: TObject);
begin if Assigned(FOnBatchAudit) then FOnBatchAudit(Sender); end;
procedure TSingleTableHelper.actFirstExecute(Sender: TObject); begin DoFirstPage; end;
procedure TSingleTableHelper.actPriorExecute(Sender: TObject); begin DoPriorPage; end;
procedure TSingleTableHelper.actNextExecute(Sender: TObject); begin DoNextPage; end;
procedure TSingleTableHelper.actLastExecute(Sender: TObject); begin DoLastPage; end;
procedure TSingleTableHelper.grdMainViewDblClick(Sender: TObject);
begin if Assigned(FOnDblClickGrid) then FOnDblClickGrid(Sender) else if Assigned(FOnEdit) then FOnEdit(Sender); end;

procedure TSingleTableHelper.DoExportExcel;
var Dlg: TSaveDialog;
begin
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Filter := 'Excel Files (*.xlsx)|*.xlsx'; Dlg.DefaultExt := 'xlsx';
    if Dlg.Execute then FcdsMaster.ExportToExcel(Dlg.FileName);
  finally Dlg.Free; end;
end;

procedure TSingleTableHelper.DoImportExcel;
var Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(nil);
  try
    Dlg.Filter := 'Excel Files (*.xlsx;*.xls)|*.xlsx;*.xls';
    if Dlg.Execute then
    begin
      FcdsMaster.ImportFromExcel(Dlg.FileName);
      ShowMessage(Format(STplMsgImportSuccess, [0]));
    end;
  finally Dlg.Free; end;
end;

procedure TSingleTableHelper.DoFirstPage;
begin
  FcdsMaster.PageIndex := 1;
  FcdsMaster.OpenData(FcdsMaster.SQLText);
  BuildGridColumns; UpdateStatus;
end;

procedure TSingleTableHelper.DoPriorPage;
begin FcdsMaster.PrevPage; UpdateStatus; end;

procedure TSingleTableHelper.DoNextPage;
begin FcdsMaster.NextPage; UpdateStatus; end;

procedure TSingleTableHelper.DoLastPage;
var TotalPages: Integer;
begin
  if FcdsMaster.PageSize > 0 then
  begin
    TotalPages := (FcdsMaster.TotalCount + FcdsMaster.PageSize - 1) div FcdsMaster.PageSize;
    FcdsMaster.PageIndex := TotalPages;
    FcdsMaster.OpenData(FcdsMaster.SQLText);
    BuildGridColumns; UpdateStatus;
  end;
end;

end.
