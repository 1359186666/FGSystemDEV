unit ufrmgridconfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset,
  ufrmbase, ufrmsingletablehelper;

type
  TGridConfigFrm = class(TFrmBase)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FHelper: TSingleTableHelper;
    procedure DoRefresh(Sender: TObject);
    procedure DoDelete(Sender: TObject);
  protected
    procedure DoCreate; override;
  end;

implementation

{$R *.dfm}

procedure TGridConfigFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnRefresh := DoRefresh;
  FHelper.OnDelete := DoDelete;
  inherited;
end;

procedure TGridConfigFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TGridConfigFrm.DoCreate;
begin
  Caption := SConfigGridTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.ApplyPermissions;
    FHelper.OpenData(
      'SELECT gc.*, ds.DatasetName, mc.ModuleCaption ' +
      'FROM sys_GridColumnConfig gc ' +
      'LEFT JOIN sys_DataSetConfig ds ON gc.DatasetConfigID = ds.ID ' +
      'LEFT JOIN sys_ModuleConfig mc ON ds.ModuleID = mc.ID');
  end;
end;

procedure TGridConfigFrm.DoRefresh(Sender: TObject);
begin
  FHelper.OpenData(
    'SELECT gc.*, ds.DatasetName, mc.ModuleCaption ' +
    'FROM sys_GridColumnConfig gc ' +
    'LEFT JOIN sys_DataSetConfig ds ON gc.DatasetConfigID = ds.ID ' +
    'LEFT JOIN sys_ModuleConfig mc ON ds.ModuleID = mc.ID');
end;

procedure TGridConfigFrm.DoDelete(Sender: TObject);
begin
  FHelper.MasterCDS.Delete;
end;

end.
