unit umainfrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Menus, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ActnList,
  Vcl.StdCtrls, Vcl.ExtCtrls, System.ImageList,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, uuser, urole, upermissionmgr,
  uconfigmanager, ulanguagemgr, ufrmbase;

type
  TMainFrm = class(TForm)
    mmMain: TMainMenu;
    miFile: TMenuItem;
    miExit: TMenuItem;
    miWindow: TMenuItem;
    miCascade: TMenuItem;
    miTileH: TMenuItem;
    miTileV: TMenuItem;
    miCloseAll: TMenuItem;
    N1: TMenuItem;
    miHelp: TMenuItem;
    miAbout: TMenuItem;
    miAdmin: TMenuItem;
    miPermission: TMenuItem;
    miModuleConfig: TMenuItem;
    miUserMgr: TMenuItem;
    miRoleMgr: TMenuItem;
    miLangMgr: TMenuItem;
    miChangePwd: TMenuItem;
    miLogout: TMenuItem;
    N2: TMenuItem;
    tbMain: TToolBar;
    btnLogout: TToolButton;
    btnAdmin: TToolButton;
    sbMain: TStatusBar;
    alMain: TActionList;
    actExit: TAction;
    actLogout: TAction;
    actCascade: TAction;
    actTileH: TAction;
    actTileV: TAction;
    actCloseAll: TAction;
    actAbout: TAction;
    actUserMgr: TAction;
    actRoleMgr: TAction;
    actPermissionMgr: TAction;
    actModuleConfig: TAction;
    actLangMgr: TAction;
    actChangePwd: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actLogoutExecute(Sender: TObject);
    procedure actCascadeExecute(Sender: TObject);
    procedure actTileHExecute(Sender: TObject);
    procedure actTileVExecute(Sender: TObject);
    procedure actCloseAllExecute(Sender: TObject);
    procedure actAboutExecute(Sender: TObject);
    procedure actUserMgrExecute(Sender: TObject);
    procedure actRoleMgrExecute(Sender: TObject);
    procedure actPermissionMgrExecute(Sender: TObject);
    procedure actModuleConfigExecute(Sender: TObject);
    procedure actLangMgrExecute(Sender: TObject);
    procedure actChangePwdExecute(Sender: TObject);
  private
    FTCPClient: TTCPClient;
    FUser: TUser;
    FRole: TRole;
    FPermissionMgr: TPermissionManager;
    FConfigManager: TConfigManager;
    FLanguageManager: TLanguageManager;
    procedure ShowMDIChild(AChild: TForm); overload;
    procedure UpdateStatusBar;
    procedure UpdateMenuPermissions;
    procedure SetMenuPermission(AMenu: TMenuItem; const APermCode: string);
  public
    property TCPClient: TTCPClient read FTCPClient;
    property LoginUser: TUser read FUser;
    property LoginRole: TRole read FRole;
    property PermissionManager: TPermissionManager read FPermissionMgr;
    property ConfigManager: TConfigManager read FConfigManager;
    property LanguageManager: TLanguageManager read FLanguageManager;

    procedure Initialize(ATCPClient: TTCPClient; AUser: TUser; ARole: TRole;
      APermMgr: TPermissionManager; AConfigMgr: TConfigManager;
      ALangMgr: TLanguageManager);
  end;

implementation

{$R *.dfm}

uses
  ufrmusermgr, ufrmrolemgr, ufrmmoduleconfig, ufrmlookupconfig,
  ufrmgridconfig, ufrmpanelconfig, ufrmbuttonconfig,
  ufrmpermissionmgr, ufrmchangepwd, ufrmservermonitor;

procedure TMainFrm.FormCreate(Sender: TObject);
begin
  Caption := SAppTitle + ' v' + SAppVersion;
  if Assigned(sbMain) and (sbMain.Panels.Count > 0) then
    sbMain.Panels[0].Text := SMainStatusOffline;
end;

procedure TMainFrm.Initialize(ATCPClient: TTCPClient; AUser: TUser;
  ARole: TRole; APermMgr: TPermissionManager; AConfigMgr: TConfigManager;
  ALangMgr: TLanguageManager);
begin
  FTCPClient := ATCPClient;
  FUser := AUser;
  FRole := ARole;
  FPermissionMgr := APermMgr;
  FConfigManager := AConfigMgr;
  FLanguageManager := ALangMgr;
end;

procedure TMainFrm.FormShow(Sender: TObject);
begin
  try
    UpdateStatusBar;
    UpdateMenuPermissions;

    if Assigned(FUser) then
    begin
      miAdmin.Visible := FUser.CurrentUser.IsSuperAdmin;
      btnAdmin.Visible := FUser.CurrentUser.IsSuperAdmin;
    end;

    if Assigned(FLanguageManager) then
      FLanguageManager.TranslateForm(Self, 'MainForm');
  except
  end;
end;

procedure TMainFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMainFrm.UpdateStatusBar;
begin
  if Assigned(FUser) and FUser.IsLoggedIn then
  begin
    sbMain.Panels[0].Text := FUser.CurrentUser.RealName + ' - ' + SMainStatusOnline;
    sbMain.Panels[1].Text := FormatDateTime('yyyy-MM-dd HH:mm', Now);
  end;
end;

procedure TMainFrm.UpdateMenuPermissions;
begin
  if Assigned(FPermissionMgr) then
  begin
    SetMenuPermission(miUserMgr, 'UserMgr.View');
    SetMenuPermission(miRoleMgr, 'RoleMgr.View');
    SetMenuPermission(miPermission, 'Permission.View');
    SetMenuPermission(miModuleConfig, 'ModuleConfig.View');
    SetMenuPermission(miLangMgr, 'LangMgr.View');
  end;
end;

procedure TMainFrm.SetMenuPermission(AMenu: TMenuItem; const APermCode: string);
begin
  if Assigned(FPermissionMgr) then
    AMenu.Visible := FPermissionMgr.HasPermission(APermCode);
end;

procedure TMainFrm.ShowMDIChild(AChild: TForm);
var
  I: Integer;
begin
  AChild.FormStyle := fsMDIChild;

  for I := 0 to MDIChildCount - 1 do
  begin
    if MDIChildren[I].ClassName = AChild.ClassName then
    begin
      MDIChildren[I].BringToFront;
      AChild.Free;
      Exit;
    end;
  end;

  if AChild is TFrmBase then
  begin
    TFrmBase(AChild).SetTCPClient(FTCPClient);
    TFrmBase(AChild).SetUser(FUser);
    TFrmBase(AChild).SetRole(FRole);
    TFrmBase(AChild).SetPermissionManager(FPermissionMgr);
    TFrmBase(AChild).SetConfigManager(FConfigManager);
    TFrmBase(AChild).SetLanguageManager(FLanguageManager);
    TFrmBase(AChild).DoCreate;
  end;

  AChild.Show;
end;

procedure TMainFrm.actExitExecute(Sender: TObject);
begin
  if FUser.IsLoggedIn then
    FUser.Logout;
  Close;
end;

procedure TMainFrm.actLogoutExecute(Sender: TObject);
begin
  FUser.Logout;

  // close all children
  while MDIChildCount > 0 do
    MDIChildren[0].Close;

  // show login again
  FTCPClient.Disconnect;
  ModalResult := mrCancel;
end;

procedure TMainFrm.actCascadeExecute(Sender: TObject);
begin
  Cascade;
end;

procedure TMainFrm.actTileHExecute(Sender: TObject);
begin
  TileMode := tbHorizontal;
  Tile;
end;

procedure TMainFrm.actTileVExecute(Sender: TObject);
begin
  TileMode := tbVertical;
  Tile;
end;

procedure TMainFrm.actCloseAllExecute(Sender: TObject);
begin
  while MDIChildCount > 0 do
    MDIChildren[0].Close;
end;

procedure TMainFrm.actAboutExecute(Sender: TObject);
begin
  Application.MessageBox(
    PChar(SAppTitle + #13#10 + 'Version: ' + SAppVersion),
    PChar(SMainMenuAbout), MB_OK or MB_ICONINFORMATION);
end;

procedure TMainFrm.actUserMgrExecute(Sender: TObject);
begin
  ShowMDIChild(TUserMgrFrm.Create(Self));
end;

procedure TMainFrm.actRoleMgrExecute(Sender: TObject);
begin
  ShowMDIChild(TRoleMgrFrm.Create(Self));
end;

procedure TMainFrm.actPermissionMgrExecute(Sender: TObject);
begin
  ShowMDIChild(TPermissionMgrFrm.Create(Self));
end;

procedure TMainFrm.actModuleConfigExecute(Sender: TObject);
begin
  ShowMDIChild(TModuleConfigFrm.Create(Self));
end;

procedure TMainFrm.actLangMgrExecute(Sender: TObject);
begin
  // ShowMDIChild(TLookupConfigFrm.Create(Self));
end;

procedure TMainFrm.actChangePwdExecute(Sender: TObject);
begin
  with TChangePwdFrm.Create(Self) do
  begin
    SetTCPClient(FTCPClient);
    SetUser(FUser);
    SetLanguageManager(FLanguageManager);
    DoCreate;
    ShowModal;
    Free;
  end;
end;

end.
