unit ufrmpanelconfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs,
  Data.DB, uappdefines, uapptypes, uappres,
  utcpclient, uappclientdataset,
  ufrmbase, ufrmsingletablehelper;

type
  TPanelConfigFrm = class(TFrmBase)
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

procedure TPanelConfigFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnRefresh := DoRefresh;
  FHelper.OnDelete := DoDelete;
  inherited;
end;

procedure TPanelConfigFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin Action := caFree; end;

procedure TPanelConfigFrm.DoCreate;
begin
  Caption := SConfigPanelTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.OpenData(
      'SELECT pc.*, mc.ModuleCaption FROM sys_PanelControlConfig pc ' +
      'LEFT JOIN sys_ModuleConfig mc ON pc.ModuleID = mc.ID');
  end;
end;

procedure TPanelConfigFrm.DoRefresh(Sender: TObject);
begin FHelper.OpenData(FHelper.MasterCDS.SQLText); end;

procedure TPanelConfigFrm.DoDelete(Sender: TObject);
begin FHelper.MasterCDS.Delete; end;

end.
