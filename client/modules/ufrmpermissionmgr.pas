unit ufrmpermissionmgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.CheckLst, Vcl.ActnList, Vcl.ToolWin,
  Data.DB, Datasnap.DBClient,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, upermissionmgr, urole, uuser,
  ufrmbase, ufrmmultitable;

type
  TPermissionMgrFrm = class(TFrmMultiTable)
    actGrant: TAction;
    actRevoke: TAction;
    actRefreshPermItems: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actGrantExecute(Sender: TObject);
    procedure actRevokeExecute(Sender: TObject);
    procedure actRefreshPermItemsExecute(Sender: TObject);
  private
    FPermCDS: TAppClientDataSet;
    function GetSelectedPermissions(AGranted: Boolean): TStringList;
    procedure RefreshPermissionGrid;
    procedure GrantPerm(ARoleID: Integer; const APermCode: string; AIsGranted: Boolean);
    procedure RevokePerm(ARoleID: Integer; const APermCode: string);
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
    procedure SetMasterDetailLink; override;
  end;

implementation

{$R *.dfm}

procedure TPermissionMgrFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  FPermCDS := TAppClientDataSet.Create(Self);
  inherited;
end;

procedure TPermissionMgrFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_Roles';
  cdsMaster.KeyFields := 'RoleID';
  cdsMaster.SQLText := 'SELECT RoleID, RoleName, Remark FROM sys_Roles ORDER BY RoleID';

  cdsDetail1.AssignTCPClient(FTCPClient);
  cdsDetail1.TableName := 'sys_RolePerm';
  cdsDetail1.KeyFields := 'ID';

  Caption := SPermTitle;

  inherited;
end;

procedure TPermissionMgrFrm.DoApplyPermissions;
begin
  inherited;
  actGrant.Visible := True;
  actRevoke.Visible := True;
  actRefreshPermItems.Visible := True;
end;

procedure TPermissionMgrFrm.SetMasterDetailLink;
begin
  RefreshPermissionGrid;
end;

procedure TPermissionMgrFrm.RefreshPermissionGrid;
var
  RoleID: Integer;
begin
  if cdsMaster.IsEmpty then Exit;

  RoleID := cdsMaster.FieldByName('RoleID').AsInteger;

  cdsDetail1.SQLText := Format(
    'SELECT pi.*, ' +
    'CASE WHEN rp.PermID IS NOT NULL AND rp.IsGranted = 1 THEN 1 ELSE 0 END AS IsGranted ' +
    'FROM sys_PermItems pi ' +
    'LEFT JOIN sys_RolePerm rp ON pi.PermID = rp.PermID AND rp.RoleID = %d ' +
    'WHERE pi.IsActive = 1 ' +
    'ORDER BY pi.ModuleName, pi.PermID',
    [RoleID]);

  cdsDetail1.OpenData(cdsDetail1.SQLText);
end;

procedure TPermissionMgrFrm.GrantPerm(ARoleID: Integer; const APermCode: string;
  AIsGranted: Boolean);
begin
  if Assigned(FRole) then
    FRole.GrantPermission(ARoleID, APermCode, AIsGranted);
end;

procedure TPermissionMgrFrm.RevokePerm(ARoleID: Integer; const APermCode: string);
begin
  if Assigned(FRole) then
    FRole.RevokePermission(ARoleID, APermCode);
end;

function TPermissionMgrFrm.GetSelectedPermissions(AGranted: Boolean): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  if cdsDetail1.Active and not cdsDetail1.IsEmpty then
  begin
    cdsDetail1.First;
    while not cdsDetail1.Eof do
    begin
      if (cdsDetail1.FieldByName('IsGranted').AsInteger = 1) = AGranted then
        Result.Add(cdsDetail1.FieldByName('PermCode').AsString);
      cdsDetail1.Next;
    end;
  end;
end;

procedure TPermissionMgrFrm.actGrantExecute(Sender: TObject);
var
  RoleID: Integer;
begin
  if cdsMaster.IsEmpty then Exit;
  RoleID := cdsMaster.FieldByName('RoleID').AsInteger;

  if cdsDetail1.Active and not cdsDetail1.IsEmpty then
  begin
    cdsDetail1.First;
    while not cdsDetail1.Eof do
    begin
      if cdsDetail1.FieldByName('IsGranted').AsInteger = 0 then
        GrantPerm(RoleID, cdsDetail1.FieldByName('PermCode').AsString, True);
      cdsDetail1.Next;
    end;
  end;

  RefreshPermissionGrid;
  Application.MessageBox(PChar('All permissions granted'), PChar(Caption),
    MB_OK or MB_ICONINFORMATION);
end;

procedure TPermissionMgrFrm.actRevokeExecute(Sender: TObject);
var
  RoleID: Integer;
begin
  if cdsMaster.IsEmpty then Exit;
  RoleID := cdsMaster.FieldByName('RoleID').AsInteger;

  if Application.MessageBox('Revoke all permissions for this role?',
    PChar(Caption), MB_YESNO or MB_ICONQUESTION) <> IDYES then
    Exit;

  if cdsDetail1.Active and not cdsDetail1.IsEmpty then
  begin
    cdsDetail1.First;
    while not cdsDetail1.Eof do
    begin
      if cdsDetail1.FieldByName('IsGranted').AsInteger = 1 then
        RevokePerm(RoleID, cdsDetail1.FieldByName('PermCode').AsString);
      cdsDetail1.Next;
    end;
  end;

  RefreshPermissionGrid;
  Application.MessageBox(PChar('All permissions revoked'), PChar(Caption),
    MB_OK or MB_ICONINFORMATION);
end;

procedure TPermissionMgrFrm.actRefreshPermItemsExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to MDIChildCount - 1 do
    FPermissionMgr.RefreshModulePermissions(Application.MainForm);

  RefreshPermissionGrid;

  Application.MessageBox(PChar(SPermMsgRefreshOK), PChar(Caption),
    MB_OK or MB_ICONINFORMATION);
end;

end.
