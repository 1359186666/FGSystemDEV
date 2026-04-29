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
  ufrmsingletablehelper in 'client\template\ufrmsingletablehelper.pas',
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
  SavedTCP: TTCPClient;
  SavedUser: TUser;
  SavedRole: TRole;
  SavedPerm: TPermissionManager;
  SavedLang: TLanguageManager;
  LoginOk: Boolean;
begin
  Application.Initialize;

  LoginFrm := TLoginFrm.Create(nil);
  try
    LoginOk := (LoginFrm.ShowModal = mrOk);
    if LoginOk then
    begin
      SavedTCP := LoginFrm.TCPClient;
      SavedUser := LoginFrm.LoginUser;
      SavedRole := LoginFrm.LoginRole;
      SavedPerm := LoginFrm.PermissionManager;
      SavedLang := LoginFrm.LanguageManager;
    end;
  finally
    LoginFrm.Free;
  end;

  if not LoginOk then Exit;

  Application.CreateForm(TMainFrm, MainFrm);
  MainFrm.Initialize(SavedTCP, SavedUser, SavedRole, SavedPerm,
    TConfigManager.Create(SavedTCP), SavedLang);

  Application.Run;
end.
