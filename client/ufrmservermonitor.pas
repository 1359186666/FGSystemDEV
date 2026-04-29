unit ufrmservermonitor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.DateUtils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ActnList, Vcl.ToolWin,
  Data.DB, Datasnap.DBClient,
  utcpclient, uappclientdataset,
  ufrmbase;

type
  TServerMonitorFrm = class(TFrmBase)
    pnlStatus: TPanel;
    lblConnections: TLabel;
    lblDBStatus: TLabel;
    lblUptime: TLabel;
    mmInfo: TMemo;
    Timer1: TTimer;
    tbActions: TToolBar;
    btnRefresh: TToolButton;
    actRefresh: TAction;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
  private
    FStartTime: TDateTime;
    procedure RefreshStatus;
  protected
    procedure DoCreate; override;
  end;

implementation

{$R *.dfm}

procedure TServerMonitorFrm.FormCreate(Sender: TObject);
begin
  inherited;
  FStartTime := Now;
end;

procedure TServerMonitorFrm.DoCreate;
begin
  inherited;
  Caption := 'Server Monitor';
  RefreshStatus;
  Timer1.Enabled := True;
end;

procedure TServerMonitorFrm.Timer1Timer(Sender: TObject);
begin
  RefreshStatus;
end;

procedure TServerMonitorFrm.RefreshStatus;
var
  CDS: TAppClientDataSet;
  UpSecs: Integer;
begin
  if FTCPClient = nil then Exit;
  if not FTCPClient.IsConnected then
  begin
    lblConnections.Caption := 'Connections: Disconnected';
    lblDBStatus.Caption := 'Database: Unknown';
    Exit;
  end;

  UpSecs := SecondsBetween(Now, FStartTime);
  lblUptime.Caption := Format('Uptime: %d days %d hours %d minutes',
    [UpSecs div 86400, (UpSecs mod 86400) div 3600, (UpSecs mod 3600) div 60]);

  lblConnections.Caption := 'Connections: Connected';
  lblDBStatus.Caption := 'Database: Connected';

  try
    CDS := TAppClientDataSet.Create(nil);
    try
      CDS.AssignTCPClient(FTCPClient);
      CDS.OpenData('SELECT 1 AS Test');
      lblDBStatus.Caption := 'Database: OK';
    finally
      CDS.Free;
    end;
  except
    lblDBStatus.Caption := 'Database: Error';
  end;
end;

procedure TServerMonitorFrm.actRefreshExecute(Sender: TObject);
begin
  RefreshStatus;
end;

end.
