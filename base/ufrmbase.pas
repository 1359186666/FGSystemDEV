unit ufrmbase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ActnList,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, upermissionmgr, urole, uuser,
  uconfigmanager, uconfigtypes, ulanguagemgr;

type
  TFrmBase = class(TForm)
  protected
    FTCPClient: TTCPClient;
    FPermissionMgr: TPermissionManager;
    FUser: TUser;
    FRole: TRole;
    FConfigManager: TConfigManager;
    FLanguageManager: TLanguageManager;
    FFormPermissionsLoaded: Boolean;
    FConfigLoaded: Boolean;
    FLangLoaded: Boolean;

    procedure DoApplyConfig; virtual;
    function GetLangSectionName: string; virtual;
    procedure SetCaption(const ACaption: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoCreate; virtual;
    procedure DoApplyPermissions; virtual;
    procedure DoLoadConfig; virtual;
    procedure DoLoadLanguage; virtual;

    procedure SetTCPClient(AClient: TTCPClient);
    procedure SetPermissionManager(AMgr: TPermissionManager);
    procedure SetUser(AUser: TUser);
    procedure SetRole(ARole: TRole);
    procedure SetConfigManager(AMgr: TConfigManager);
    procedure SetLanguageManager(AMgr: TLanguageManager);

    procedure RefreshPermissions;
    procedure RefreshConfig;
    procedure RefreshLanguage;
  end;

implementation

constructor TFrmBase.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFormPermissionsLoaded := False;
  FConfigLoaded := False;
  FLangLoaded := False;
end;

destructor TFrmBase.Destroy;
begin
  inherited;
end;

procedure TFrmBase.SetTCPClient(AClient: TTCPClient);
begin
  FTCPClient := AClient;
end;

procedure TFrmBase.SetPermissionManager(AMgr: TPermissionManager);
begin
  FPermissionMgr := AMgr;
end;

procedure TFrmBase.SetUser(AUser: TUser);
begin
  FUser := AUser;
end;

procedure TFrmBase.SetRole(ARole: TRole);
begin
  FRole := ARole;
end;

procedure TFrmBase.SetConfigManager(AMgr: TConfigManager);
begin
  FConfigManager := AMgr;
end;

procedure TFrmBase.SetLanguageManager(AMgr: TLanguageManager);
begin
  FLanguageManager := AMgr;
end;

procedure TFrmBase.DoCreate;
begin
  if not FConfigLoaded then
    DoLoadConfig;
  if not FFormPermissionsLoaded then
    DoApplyPermissions;
  if not FLangLoaded then
    DoLoadLanguage;
end;

procedure TFrmBase.DoApplyPermissions;
begin
  if Assigned(FPermissionMgr) then
  begin
    FPermissionMgr.ApplyPermissions(Self);
    FFormPermissionsLoaded := True;
  end;
end;

procedure TFrmBase.DoLoadConfig;
begin
  if Assigned(FConfigManager) then
  begin
    if FConfigManager.HasConfig(ClassName) then
      FConfigManager.BuildFormFromConfig(Self,
        FConfigManager.GetModuleConfig(ClassName));
    FConfigLoaded := True;
  end;
end;

procedure TFrmBase.DoLoadLanguage;
begin
  if Assigned(FLanguageManager) then
  begin
    FLanguageManager.TranslateForm(Self, GetLangSectionName);
    FLangLoaded := True;
  end;
end;

procedure TFrmBase.DoApplyConfig;
begin
end;

function TFrmBase.GetLangSectionName: string;
begin
  Result := ClassName;
  Result := StringReplace(Result, 'TFrm', '', []);
end;

procedure TFrmBase.SetCaption(const ACaption: string);
begin
  Caption := ACaption;
end;

procedure TFrmBase.RefreshPermissions;
begin
  FFormPermissionsLoaded := False;
  DoApplyPermissions;
end;

procedure TFrmBase.RefreshConfig;
begin
  FConfigLoaded := False;
  if Assigned(FConfigManager) then
    FConfigManager.RefreshCache;
  DoLoadConfig;
end;

procedure TFrmBase.RefreshLanguage;
begin
  FLangLoaded := False;
  DoLoadLanguage;
end;

end.
