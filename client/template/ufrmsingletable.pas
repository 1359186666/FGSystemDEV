unit ufrmsingletable;

interface

uses
  Winapi.Windows, Winapi.Messages,   System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.Generics.Collections,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ComCtrls, Vcl.ToolWin,
  Data.DB, Datasnap.DBClient,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, upermissionmgr, ulanguagemgr, uconfigmanager,
  ufrmbase;

type
  TFrmSingleTable = class(TFrmBase)
    gbxSearch: TGroupBox;
    pnlTop: TPanel;
    pnlBottom: TPanel;
    grdMain: TcxGrid;
    grdMainView: TcxGridDBTableView;
    grdMainLevel: TcxGridLevel;
    sbMain: TStatusBar;
    alActions: TActionList;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    actRefresh: TAction;
    actSearch: TAction;
    actReset: TAction;
    actExport: TAction;
    actImport: TAction;
    actPrint: TAction;
    actCopy: TAction;
    actBatchDelete: TAction;
    actBatchAudit: TAction;
    actFirst: TAction;
    actPrior: TAction;
    actNext: TAction;
    actLast: TAction;
    tbActions: TToolBar;
    btnAdd: TToolButton;
    btnEdit: TToolButton;
    btnDelete: TToolButton;
    btnRefresh: TToolButton;
    btnSearch: TToolButton;
    btnExport: TToolButton;
    btnImport: TToolButton;
    btnPrint: TToolButton;
    btnCopy: TToolButton;
    btnBatchDelete: TToolButton;
    btnBatchAudit: TToolButton;
    btnClose: TToolButton;
    Splitter1: TSplitter;
    pnlDetail: TPanel;
    dtsMain: TDataSource;
    cdsMaster: TAppClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actSearchExecute(Sender: TObject);
    procedure actResetExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
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
  private
    FCanAdd: Boolean;
    FCanEdit: Boolean;
    FCanDelete: Boolean;
    FCanExport: Boolean;
    FCanImport: Boolean;
    FCanPrint: Boolean;
    FCanCopy: Boolean;
    FCanBatchDelete: Boolean;
    FCanBatchAudit: Boolean;
  protected
    procedure DoCreate; override;
    procedure DoLoadConfig; override;
    procedure DoApplyPermissions; override;

    procedure OpenData; virtual;
    procedure BuildGridColumns; virtual;
    procedure PerformSearch; virtual;
    procedure ResetSearch; virtual;
    procedure DoAdd; virtual;
    procedure DoEdit; virtual;
    procedure DoDelete; virtual;
    procedure DoExportExcel; virtual;
    procedure DoImportExcel; virtual;
    procedure DoPrint; virtual;
    procedure DoCopyRow; virtual;
    procedure DoBatchDelete; virtual;
    procedure DoBatchAudit; virtual;
    procedure DoFirstPage; virtual;
    procedure DoPriorPage; virtual;
    procedure DoNextPage; virtual;
    procedure DoLastPage; virtual;
    procedure UpdateStatus; virtual;
  public
    property MasterCDS: TAppClientDataSet read cdsMaster;
  end;

implementation

{$R *.dfm}

procedure TFrmSingleTable.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  cdsMaster.AssignTCPClient(FTCPClient);
  dtsMain.DataSet := cdsMaster;
  inherited;
end;

procedure TFrmSingleTable.DoCreate;
begin
  inherited;
  DoLoadConfig;
  DoApplyPermissions;
  if Assigned(FTCPClient) then
  begin
    OpenData;
    UpdateStatus;
  end;
end;

procedure TFrmSingleTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if cdsMaster.State in [dsEdit, dsInsert] then
    cdsMaster.Cancel;
  if cdsMaster.ChangeCount > 0 then
  begin
    if Application.MessageBox(PChar(STplMsgDataChanged), PChar(Caption),
      MB_YESNO or MB_ICONQUESTION) = IDYES then
      cdsMaster.ApplyUpdates(0);
  end;
  Action := caFree;
end;

procedure TFrmSingleTable.DoApplyPermissions;
var
  BaseCode: string;
begin
  inherited;

  BaseCode := StringReplace(ClassName, 'TFrm', '', []);
  BaseCode := StringReplace(BaseCode, 'TForm', '', []);

  if Assigned(FPermissionMgr) then
  begin
    FCanAdd := FPermissionMgr.HasPermission(BaseCode + '.Add');
    FCanEdit := FPermissionMgr.HasPermission(BaseCode + '.Edit');
    FCanDelete := FPermissionMgr.HasPermission(BaseCode + '.Delete');
    FCanExport := FPermissionMgr.HasPermission(BaseCode + '.Export');
    FCanImport := FPermissionMgr.HasPermission(BaseCode + '.Import');
    FCanPrint := FPermissionMgr.HasPermission(BaseCode + '.Print');
    FCanCopy := FPermissionMgr.HasPermission(BaseCode + '.Copy');
    FCanBatchDelete := FPermissionMgr.HasPermission(BaseCode + '.BatchDelete');
    FCanBatchAudit := FPermissionMgr.HasPermission(BaseCode + '.BatchAudit');
  end
  else
  begin
    FCanAdd := True;
    FCanEdit := True;
    FCanDelete := True;
    FCanExport := True;
    FCanImport := True;
    FCanPrint := True;
    FCanCopy := True;
    FCanBatchDelete := True;
    FCanBatchAudit := True;
  end;

  actAdd.Visible := FCanAdd;
  actEdit.Visible := FCanEdit;
  actDelete.Visible := FCanDelete;
  actExport.Visible := FCanExport;
  actImport.Visible := FCanImport;
  actPrint.Visible := FCanPrint;
  actCopy.Visible := FCanCopy;
  actBatchDelete.Visible := FCanBatchDelete;
  actBatchAudit.Visible := FCanBatchAudit;
end;

procedure TFrmSingleTable.DoLoadConfig;
begin
  inherited;
  // subclass can override to load grid columns, search panels etc.
end;

procedure TFrmSingleTable.OpenData;
begin
  // subclass must set cdsMaster.SQLText before calling this
  if cdsMaster.SQLText = '' then Exit;

  cdsMaster.OpenData(cdsMaster.SQLText);
  BuildGridColumns;
end;

procedure TFrmSingleTable.BuildGridColumns;
var
  I: Integer;
  Col: TcxGridDBColumn;
begin
  grdMainView.BeginUpdate;
  try
    grdMainView.ClearItems;

    for I := 0 to cdsMaster.Fields.Count - 1 do
    begin
      if not cdsMaster.Fields[I].Visible then Continue;

      Col := grdMainView.CreateColumn;
      Col.DataBinding.FieldName := cdsMaster.Fields[I].FieldName;
      Col.Caption := cdsMaster.Fields[I].DisplayLabel;
      Col.Width := cdsMaster.Fields[I].DisplayWidth;
      if Col.Width < 50 then
        Col.Width := 80;
    end;
  finally
    grdMainView.EndUpdate;
  end;
end;

procedure TFrmSingleTable.PerformSearch;
begin
  cdsMaster.PageIndex := 1;
  cdsMaster.Params.Clear;
  OpenData;
  UpdateStatus;
end;

procedure TFrmSingleTable.ResetSearch;
begin
  OpenData;
  UpdateStatus;
end;

procedure TFrmSingleTable.DoAdd;
begin
  cdsMaster.Append;
end;

procedure TFrmSingleTable.DoEdit;
begin
  cdsMaster.Edit;
end;

procedure TFrmSingleTable.DoDelete;
begin
  if Application.MessageBox(PChar(STplConfirmDelete), PChar(Caption),
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    cdsMaster.Delete;
    if FCanDelete then
    begin
      cdsMaster.TableName := cdsMaster.TableName;
      cdsMaster.KeyFields := cdsMaster.KeyFields;
      cdsMaster.ApplyToServer;
    end;
  end;
end;

procedure TFrmSingleTable.DoExportExcel;
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

procedure TFrmSingleTable.DoImportExcel;
var
  Dlg: TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Filter := 'Excel Files (*.xlsx;*.xls)|*.xlsx;*.xls';
    if Dlg.Execute then
    begin
      cdsMaster.ImportFromExcel(Dlg.FileName, 1);
      Application.MessageBox(PChar(Format(STplMsgImportSuccess, [0])),
        PChar(Caption), MB_OK or MB_ICONINFORMATION);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TFrmSingleTable.DoPrint;
begin
  // subclass can implement FastReport printing
end;

procedure TFrmSingleTable.DoCopyRow;
begin
  if cdsMaster.IsEmpty then Exit;

  cdsMaster.Append;
  // subclass should implement field copy logic
end;

procedure TFrmSingleTable.DoBatchDelete;
var
  I: Integer;
  Row: Integer;
  SelRows: TList;
begin
  if Application.MessageBox(PChar(STplConfirmBatchDelete), PChar(Caption),
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    // subclass should implement batch delete logic
  end;
end;

procedure TFrmSingleTable.DoBatchAudit;
begin
  // subclass should implement batch audit logic
end;

procedure TFrmSingleTable.DoFirstPage;
begin
  cdsMaster.PageIndex := 1;
  OpenData;
end;

procedure TFrmSingleTable.DoPriorPage;
begin
  cdsMaster.PrevPage;
  UpdateStatus;
end;

procedure TFrmSingleTable.DoNextPage;
begin
  cdsMaster.NextPage;
  UpdateStatus;
end;

procedure TFrmSingleTable.DoLastPage;
var
  TotalPages: Integer;
begin
  if cdsMaster.PageSize > 0 then
  begin
    TotalPages := (cdsMaster.TotalCount + cdsMaster.PageSize - 1) div cdsMaster.PageSize;
    cdsMaster.PageIndex := TotalPages;
    OpenData;
  end;
end;

procedure TFrmSingleTable.UpdateStatus;
begin
  if cdsMaster.TotalCount > 0 then
    sbMain.Panels[0].Text := Format(STplStatusRecordCount, [cdsMaster.TotalCount]);
end;

procedure TFrmSingleTable.grdMainViewDblClick(Sender: TObject);
begin
  DoEdit;
end;

procedure TFrmSingleTable.actSearchExecute(Sender: TObject);
begin PerformSearch; end;

procedure TFrmSingleTable.actResetExecute(Sender: TObject);
begin ResetSearch; end;

procedure TFrmSingleTable.actRefreshExecute(Sender: TObject);
begin OpenData; UpdateStatus; end;

procedure TFrmSingleTable.actAddExecute(Sender: TObject);
begin DoAdd; end;

procedure TFrmSingleTable.actEditExecute(Sender: TObject);
begin DoEdit; end;

procedure TFrmSingleTable.actDeleteExecute(Sender: TObject);
begin DoDelete; end;

procedure TFrmSingleTable.actExportExecute(Sender: TObject);
begin DoExportExcel; end;

procedure TFrmSingleTable.actImportExecute(Sender: TObject);
begin DoImportExcel; end;

procedure TFrmSingleTable.actPrintExecute(Sender: TObject);
begin DoPrint; end;

procedure TFrmSingleTable.actCopyExecute(Sender: TObject);
begin DoCopyRow; end;

procedure TFrmSingleTable.actBatchDeleteExecute(Sender: TObject);
begin DoBatchDelete; end;

procedure TFrmSingleTable.actBatchAuditExecute(Sender: TObject);
begin DoBatchAudit; end;

procedure TFrmSingleTable.actFirstExecute(Sender: TObject);
begin DoFirstPage; end;

procedure TFrmSingleTable.actPriorExecute(Sender: TObject);
begin DoPriorPage; end;

procedure TFrmSingleTable.actNextExecute(Sender: TObject);
begin DoNextPage; end;

procedure TFrmSingleTable.actLastExecute(Sender: TObject);
begin DoLastPage; end;

end.
