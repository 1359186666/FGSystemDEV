unit ufrmreport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ToolWin, Vcl.ComCtrls,
  Data.DB, Datasnap.DBClient,
  frxClass, frxDBSet, frxExportPDF, frxExportXLS, frxExportHTML,
  frxPreview,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, ufrmbase;

type
  TFrmReport = class(TFrmBase)
    pnlTop: TPanel;
    pnlMain: TPanel;
    frxPreview: TfrxPreview;
    frxReport: TfrxReport;
    frxDBDataset: TfrxDBDataset;
    tbActions: TToolBar;
    btnPrint: TToolButton;
    btnPreview: TToolButton;
    btnDesign: TToolButton;
    btnExportPDF: TToolButton;
    btnExportExcel: TToolButton;
    btnExportHTML: TToolButton;
    btnClose: TToolButton;
    alActions: TActionList;
    actPrint: TAction;
    actPreview: TAction;
    actDesign: TAction;
    actExportPDF: TAction;
    actExportExcel: TAction;
    actExportHTML: TAction;
    dtsReport: TDataSource;
    cdsReport: TAppClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actPreviewExecute(Sender: TObject);
    procedure actDesignExecute(Sender: TObject);
    procedure actExportPDFExecute(Sender: TObject);
    procedure actExportExcelExecute(Sender: TObject);
    procedure actExportHTMLExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FReportFile: string;
    procedure SetReportFile(const AFileName: string);
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
  public
    property ReportFile: string read FReportFile write SetReportFile;

    procedure SetDataSource(ADataSet: TDataSet);
    procedure LoadReportFile(const AFileName: string; AIsRelative: Boolean = True);
    procedure Print;
    procedure Preview;
    procedure Design;
    procedure ExportToPDF(const AFileName: string);
    procedure ExportToExcel(const AFileName: string);
    procedure ExportToHTML(const AFileName: string);
  end;

implementation

{$R *.dfm}

procedure TFrmReport.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  cdsReport.AssignTCPClient(FTCPClient);
  dtsReport.DataSet := cdsReport;
  frxDBDataset.DataSet := cdsReport;
  FReportFile := '';
  inherited;
end;

procedure TFrmReport.FormDestroy(Sender: TObject);
begin
  frxReport.Free;
  inherited;
end;

procedure TFrmReport.DoCreate;
begin
  inherited;
  DoApplyPermissions;
end;

procedure TFrmReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmReport.DoApplyPermissions;
var
  BaseCode: string;
begin
  inherited;

  BaseCode := StringReplace(ClassName, 'TFrm', '', []);
  BaseCode := StringReplace(BaseCode, 'TForm', '', []);

  if Assigned(FPermissionMgr) then
  begin
    actPrint.Visible := FPermissionMgr.HasPermission(BaseCode + '.Print');
    actDesign.Visible := FPermissionMgr.HasPermission(BaseCode + '.Design');
    actExportPDF.Visible := FPermissionMgr.HasPermission(BaseCode + '.Export');
    actExportExcel.Visible := FPermissionMgr.HasPermission(BaseCode + '.Export');
    actExportHTML.Visible := FPermissionMgr.HasPermission(BaseCode + '.Export');
  end;
end;

procedure TFrmReport.SetReportFile(const AFileName: string);
begin
  FReportFile := AFileName;
  if FileExists(AFileName) then
    frxReport.LoadFromFile(AFileName);
end;

procedure TFrmReport.SetDataSource(ADataSet: TDataSet);
begin
  if ADataSet <> nil then
  begin
    frxDBDataset.DataSet := ADataSet;
    dtsReport.DataSet := ADataSet;
  end;
end;

procedure TFrmReport.LoadReportFile(const AFileName: string; AIsRelative: Boolean);
var
  FullPath: string;
begin
  if AIsRelative then
    FullPath := ExtractFilePath(Application.ExeName) + AFileName
  else
    FullPath := AFileName;

  if not FileExists(FullPath) then
    raise Exception.CreateFmt('Report file not found: %s', [FullPath]);

  FReportFile := FullPath;
  frxReport.LoadFromFile(FullPath);
end;

procedure TFrmReport.Print;
begin
  frxReport.Print;
end;

procedure TFrmReport.Preview;
begin
  if FReportFile <> '' then
    frxReport.LoadFromFile(FReportFile);

  frxReport.PrepareReport;
  frxPreview.Report := frxReport;
  frxReport.ShowPreparedReport;
end;

procedure TFrmReport.Design;
begin
  if FReportFile <> '' then
  begin
    frxReport.LoadFromFile(FReportFile);
    frxReport.DesignReport;
  end
  else
  begin
    frxDBDataset.DataSet := cdsReport;
    frxReport.DataSet := frxDBDataset;
    frxReport.DataSetName := 'ReportData';
    frxReport.DesignReport;
  end;
end;

procedure TFrmReport.ExportToPDF(const AFileName: string);
var
  PDFExport: TfrxPDFExport;
begin
  PDFExport := TfrxPDFExport.Create(nil);
  try
    PDFExport.FileName := AFileName;
    PDFExport.ShowDialog := False;

    if FReportFile <> '' then
      frxReport.LoadFromFile(FReportFile);

    frxReport.PrepareReport;
    frxReport.Export(PDFExport);
  finally
    PDFExport.Free;
  end;
end;

procedure TFrmReport.ExportToExcel(const AFileName: string);
var
  XLSExport: TfrxXLSExport;
begin
  XLSExport := TfrxXLSExport.Create(nil);
  try
    XLSExport.FileName := AFileName;
    XLSExport.ShowDialog := False;

    if FReportFile <> '' then
      frxReport.LoadFromFile(FReportFile);

    frxReport.PrepareReport;
    frxReport.Export(XLSExport);
  finally
    XLSExport.Free;
  end;
end;

procedure TFrmReport.ExportToHTML(const AFileName: string);
var
  HTMLExport: TfrxHTMLExport;
begin
  HTMLExport := TfrxHTMLExport.Create(nil);
  try
    HTMLExport.FileName := AFileName;
    HTMLExport.ShowDialog := False;

    if FReportFile <> '' then
      frxReport.LoadFromFile(FReportFile);

    frxReport.PrepareReport;
    frxReport.Export(HTMLExport);
  finally
    HTMLExport.Free;
  end;
end;

procedure TFrmReport.actPrintExecute(Sender: TObject);
begin Print; end;

procedure TFrmReport.actPreviewExecute(Sender: TObject);
begin Preview; end;

procedure TFrmReport.actDesignExecute(Sender: TObject);
begin Design; end;

procedure TFrmReport.actExportPDFExecute(Sender: TObject);
begin
  with TSaveDialog.Create(Self) do
  try
    Filter := 'PDF Files (*.pdf)|*.pdf';
    DefaultExt := 'pdf';
    if Execute then
      ExportToPDF(FileName);
  finally
    Free;
  end;
end;

procedure TFrmReport.actExportExcelExecute(Sender: TObject);
begin
  with TSaveDialog.Create(Self) do
  try
    Filter := 'Excel Files (*.xls)|*.xls';
    DefaultExt := 'xls';
    if Execute then
      ExportToExcel(FileName);
  finally
    Free;
  end;
end;

procedure TFrmReport.actExportHTMLExecute(Sender: TObject);
begin
  with TSaveDialog.Create(Self) do
  try
    Filter := 'HTML Files (*.html)|*.html';
    DefaultExt := 'html';
    if Execute then
      ExportToHTML(FileName);
  finally
    Free;
  end;
end;

end.
