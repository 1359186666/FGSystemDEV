program app_client;

uses
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs,
  System.SysUtils,
  Winapi.Windows,
  uappdefines in 'common\uappdefines.pas',
  uapptypes in 'common\uapptypes.pas',
  uapputils in 'common\uapputils.pas',
  uappres in 'common\uappres.pas',
  ujsonprotocol in 'comm\ujsonprotocol.pas',
  utcpclient in 'comm\utcpclient.pas',
  uappclientdataset in 'data\uappclientdataset.pas',
  upermissionmgr in 'permission\upermissionmgr.pas',
  urole in 'permission\urole.pas',
  uuser in 'permission\uuser.pas',
  uconfigtypes in 'config\uconfigtypes.pas',
  uconfigloader in 'config\uconfigloader.pas',
  uconfigmanager in 'config\uconfigmanager.pas',
  ulanguagemgr in 'language\ulanguagemgr.pas',
  uexcelutils in 'excel\uexcelutils.pas',
  ufrmbase in 'base\ufrmbase.pas',
  udtmbase in 'base\udtmbase.pas',
  uloginfrm in 'client\uloginfrm.pas' {TLoginFrm},
  umainfrm in 'client\umainfrm.pas' {TMainFrm},
  ufrmsingletable in 'client\template\ufrmsingletable.pas' {TFrmSingleTable},
  ufrmmultitable in 'client\template\ufrmmultitable.pas' {TFrmMultiTable},
  ufrmreport in 'client\template\ufrmreport.pas' {TFrmReport},
  ufrmusermgr in 'client\modules\ufrmusermgr.pas' {TUserMgrFrm},
  ufrmrolemgr in 'client\modules\ufrmrolemgr.pas' {TRoleMgrFrm},
  ufrmmoduleconfig in 'client\modules\ufrmmoduleconfig.pas' {TModuleConfigFrm},
  ufrmlookupconfig in 'client\modules\ufrmlookupconfig.pas' {TLookupConfigFrm},
  ufrmgridconfig in 'client\modules\ufrmgridconfig.pas' {TGridConfigFrm},
  ufrmpanelconfig in 'client\modules\ufrmpanelconfig.pas' {TPanelConfigFrm},
  ufrmbuttonconfig in 'client\modules\ufrmbuttonconfig.pas' {TButtonConfigFrm},
  ufrmpermissionmgr in 'client\modules\ufrmpermissionmgr.pas' {TPermissionMgrFrm},
  ufrmchangepwd in 'client\modules\ufrmchangepwd.pas' {TChangePwdFrm},
  ufrmservermonitor in 'client\ufrmservermonitor.pas' {TServerMonitorFrm};

{$R *.res}

var
  LoginFrm: TLoginFrm;
  MainFrm: TMainFrm;
begin
  Application.Initialize;

  ReportMemoryLeaksOnShutdown := True;

  LoginFrm := TLoginFrm.Create(nil);
  try
    if LoginFrm.ShowModal <> mrOk then
      Exit;

    try
      Application.CreateForm(TMainFrm, MainFrm);
      MainFrm.Initialize(
        LoginFrm.TCPClient,
        LoginFrm.LoginUser,
        LoginFrm.LoginRole,
        LoginFrm.PermissionManager,
        TConfigManager.Create(LoginFrm.TCPClient),
        LoginFrm.LanguageManager
      );
      ShowMessage('Main form initialized, starting Application.Run...');
      Application.Run;
    except
      on E: Exception do
        ShowMessage('Error creating main form: ' + E.Message);
    end;

    LoginFrm.LoginUser.Logout;
  finally
    LoginFrm.Free;
  end;
end.
