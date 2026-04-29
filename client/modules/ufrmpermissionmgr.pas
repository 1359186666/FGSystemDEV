unit ufrmpermissionmgr;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, urole,
  ufrmbase, ufrmmultitablehelper;

type
  TPermissionMgrFrm = class(TFrmBase)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FHelper: TMultiTableHelper;
    FactGrant: TAction;
    FactRevoke: TAction;
    FactRefreshPerm: TAction;
    procedure DoRefresh(Sender: TObject);
    procedure actGrantExecute(Sender: TObject);
    procedure actRevokeExecute(Sender: TObject);
    procedure actRefreshPermExecute(Sender: TObject);
    procedure DoAddDetail(Sender: TObject);
  protected
    procedure DoCreate; override;
  end;

implementation

{$R *.dfm}

procedure TPermissionMgrFrm.FormCreate(Sender: TObject);
begin
  FHelper := TMultiTableHelper.Create(Self);
  FHelper.OnRefresh := DoRefresh;
  FHelper.OnAddDetail := DoAddDetail;

  FactGrant := TAction.Create(Self);
  FactGrant.Caption := 'Grant All';
  FactGrant.OnExecute := actGrantExecute;

  FactRevoke := TAction.Create(Self);
  FactRevoke.Caption := 'Revoke All';
  FactRevoke.OnExecute := actRevokeExecute;

  FactRefreshPerm := TAction.Create(Self);
  FactRefreshPerm.Caption := 'Refresh';
  FactRefreshPerm.OnExecute := actRefreshPermExecute;

  inherited;
end;

procedure TPermissionMgrFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPermissionMgrFrm.DoCreate;
begin
  Caption := SPermTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.SetPermissionManager(FPermissionMgr);
    FHelper.ApplyPermissions;
    FHelper.OpenData('SELECT * FROM sys_Roles');
  end;
end;

procedure TPermissionMgrFrm.DoRefresh(Sender: TObject);
begin
  if not FHelper.MasterCDS.IsEmpty then
  begin
    FHelper.OpenDetail(Format(
      'SELECT pi.*, ' +
      'CASE WHEN rp.PermID IS NOT NULL THEN 1 ELSE 0 END AS IsGranted ' +
      'FROM sys_PermItems pi ' +
      'LEFT JOIN sys_RolePerm rp ON pi.PermID = rp.PermID AND rp.RoleID = %d ' +
      'WHERE pi.IsActive = 1',
      [FHelper.MasterCDS.FieldByName('RoleID').AsInteger]));
  end;
end;

procedure TPermissionMgrFrm.DoAddDetail(Sender: TObject);
begin
  DoRefresh(nil);
end;

procedure TPermissionMgrFrm.actGrantExecute(Sender: TObject);
begin
  if Assigned(FRole) then
    FRole.GrantPermission(
      FHelper.MasterCDS.FieldByName('RoleID').AsInteger, '', True);
  DoRefresh(nil);
end;

procedure TPermissionMgrFrm.actRevokeExecute(Sender: TObject);
begin
  if Assigned(FRole) then
    FRole.RevokePermission(
      FHelper.MasterCDS.FieldByName('RoleID').AsInteger, '');
  DoRefresh(nil);
end;

procedure TPermissionMgrFrm.actRefreshPermExecute(Sender: TObject);
begin
  if Assigned(FPermissionMgr) then
    FPermissionMgr.RefreshModulePermissions(Application.MainForm);
  DoRefresh(nil);
end;

end.
