unit ufrmbuttonconfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Data.DB,
  uappdefines, uapptypes, uappres,
  utcpclient, uappclientdataset,
  ufrmbase, ufrmsingletablehelper;

type
  TButtonConfigFrm = class(TFrmBase)
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

procedure TButtonConfigFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnRefresh := DoRefresh;
  FHelper.OnDelete := DoDelete;
  inherited;
end;

procedure TButtonConfigFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin Action := caFree; end;

procedure TButtonConfigFrm.DoCreate;
begin
  Caption := SConfigButtonTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.OpenData(
      'SELECT bc.*, mc.ModuleCaption FROM sys_ButtonConfig bc ' +
      'LEFT JOIN sys_ModuleConfig mc ON bc.ModuleID = mc.ID');
  end;
end;

procedure TButtonConfigFrm.DoRefresh(Sender: TObject);
begin FHelper.OpenData(FHelper.MasterCDS.SQLText); end;

procedure TButtonConfigFrm.DoDelete(Sender: TObject);
begin FHelper.MasterCDS.Delete; end;

end.
