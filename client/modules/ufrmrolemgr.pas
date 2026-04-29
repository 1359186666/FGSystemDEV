unit ufrmrolemgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset,
  ufrmbase, ufrmsingletablehelper;

type
  TRoleMgrFrm = class(TFrmBase)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FHelper: TSingleTableHelper;
    FactAssignUsers: TAction;
    procedure DoAdd(Sender: TObject);
    procedure DoEdit(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoRefresh(Sender: TObject);
    procedure actAssignUsersExecute(Sender: TObject);
  protected
    procedure DoCreate; override;
  public
    property Helper: TSingleTableHelper read FHelper;
  end;

implementation

{$R *.dfm}

procedure TRoleMgrFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnAdd := DoAdd;
  FHelper.OnEdit := DoEdit;
  FHelper.OnDelete := DoDelete;
  FHelper.OnRefresh := DoRefresh;

  FactAssignUsers := TAction.Create(Self);
  FactAssignUsers.Caption := 'Assign Users';
  FactAssignUsers.OnExecute := actAssignUsersExecute;
  FactAssignUsers.Visible := True;
  FactAssignUsers.Enabled := True;

  inherited;
end;

procedure TRoleMgrFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TRoleMgrFrm.DoCreate;
begin
  Caption := SRoleMgrTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.SetPermissionManager(FPermissionMgr);
    FHelper.ApplyPermissions;
    FHelper.OpenData('SELECT RoleID, RoleName, Remark FROM sys_Roles');
  end;
end;

procedure TRoleMgrFrm.DoAdd(Sender: TObject);
begin FHelper.MasterCDS.Append; end;

procedure TRoleMgrFrm.DoEdit(Sender: TObject);
begin FHelper.MasterCDS.Edit; end;

procedure TRoleMgrFrm.DoDelete(Sender: TObject);
begin
  if FHelper.MasterCDS.FieldByName('RoleID').AsInteger = SUPER_ADMIN_ROLE_ID then
  begin
    Application.MessageBox('Cannot delete super admin role', PChar(Caption), MB_OK or MB_ICONWARNING);
    Exit;
  end;
  if Application.MessageBox(PChar(STplConfirmDelete), PChar(Caption), MB_YESNO or MB_ICONQUESTION) = IDYES then
    FHelper.MasterCDS.Delete;
end;

procedure TRoleMgrFrm.DoRefresh(Sender: TObject);
begin
  FHelper.OpenData('SELECT RoleID, RoleName, Remark FROM sys_Roles');
end;

procedure TRoleMgrFrm.actAssignUsersExecute(Sender: TObject);
begin
end;

end.
