unit ufrmrolemgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, urole,
  ufrmbase, ufrmsingletable;

type
  TRoleMgrFrm = class(TFrmSingleTable)
    actAssignUsers: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actAssignUsersExecute(Sender: TObject);
  protected
    procedure DoCreate; override;
    procedure DoAdd; override;
    procedure DoEdit; override;
    procedure DoDelete; override;
    procedure DoApplyPermissions; override;
  end;

implementation

{$R *.dfm}

procedure TRoleMgrFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  inherited;
end;

procedure TRoleMgrFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_Roles';
  cdsMaster.KeyFields := 'RoleID';
  cdsMaster.SQLText :=
    'SELECT RoleID, RoleName, Remark, ' +
    'CONVERT(NVARCHAR(19), CreateTime, 120) AS CreateTime ' +
    'FROM sys_Roles ORDER BY RoleID';
  Caption := SRoleMgrTitle;
  inherited;
end;

procedure TRoleMgrFrm.DoApplyPermissions;
begin
  inherited;
  actAssignUsers.Visible := True;
end;

procedure TRoleMgrFrm.DoAdd;
begin
  cdsMaster.Append;
  cdsMaster.FieldByName('RoleName').AsString := '';
  cdsMaster.FieldByName('Remark').AsString := '';
end;

procedure TRoleMgrFrm.DoEdit;
begin
  cdsMaster.Edit;
end;

procedure TRoleMgrFrm.DoDelete;
begin
  if cdsMaster.FieldByName('RoleID').AsInteger = SUPER_ADMIN_ROLE_ID then
  begin
    Application.MessageBox('Cannot delete super admin role', PChar(Caption),
      MB_OK or MB_ICONWARNING);
    Exit;
  end;
  inherited;
end;

procedure TRoleMgrFrm.actAssignUsersExecute(Sender: TObject);
begin
  // TODO: Show user-role assignment dialog
end;

end.
