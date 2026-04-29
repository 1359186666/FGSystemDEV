program app_server;

uses
  Vcl.Forms,
  System.SysUtils,
  Winapi.Windows,
  uappdefines in 'common\uappdefines.pas',
  uapptypes in 'common\uapptypes.pas',
  uapputils in 'common\uapputils.pas',
  ujsonprotocol in 'comm\ujsonprotocol.pas',
  utcpserver in 'comm\utcpserver.pas',
  userverinit in 'server\userverinit.pas',
  uservermethods in 'server\uservermethods.pas',
  uservercontainer in 'server\uservercontainer.pas',
  uservermain in 'server\uservermain.pas' {TServerMainFrm};

{$R *.res}

var
  SrvFrm: TServerMainFrm;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Application.CreateForm(TServerMainFrm, SrvFrm);
  Application.Run;
end.
