unit uuser;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  uappdefines, uapptypes, uapputils, uappclientdataset, utcpclient;

type
  TUser = class
  private
    FTCPClient: TTCPClient;
    FCDSUsers: TAppClientDataSet;
    FCurrentUser: TUserInfo;
  public
    constructor Create(ATCPClient: TTCPClient);
    destructor Destroy; override;

    function Login(const AUserName, APassword: string): Boolean;
    procedure Logout;
    function IsLoggedIn: Boolean;

    function LoadUsers: Boolean;
    function GetUserByID(AUserID: Integer): TUserInfo;
    function SaveUser(const AUserInfo: TUserInfo): Boolean;
    function DeleteUser(AUserID: Integer): Boolean;
    function ResetPassword(AUserID: Integer; const ANewPassword: string): Boolean;
    function ChangePassword(const AOldPwd, ANewPwd: string): Boolean;

    property CurrentUser: TUserInfo read FCurrentUser;
    function GetUsersDataSet: TDataSet;
  end;

implementation

constructor TUser.Create(ATCPClient: TTCPClient);
begin
  inherited Create;
  FTCPClient := ATCPClient;
  FCDSUsers := TAppClientDataSet.Create(nil);
  FCDSUsers.AssignTCPClient(FTCPClient);
  FillChar(FCurrentUser, SizeOf(FCurrentUser), 0);
end;

destructor TUser.Destroy;
begin
  FCDSUsers.Free;
  inherited;
end;

function TUser.Login(const AUserName, APassword: string): Boolean;
var
  CDS: TAppClientDataSet;
begin
  Result := False;

  if not FTCPClient.Login(AUserName, APassword) then
    Exit;

  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.OpenData(Format(
      'SELECT UserID, UserName, RealName, PasswordHash, Status, IsSuperAdmin ' +
      'FROM sys_Users WHERE UserName = ''%s''',
      [StringReplace(AUserName, '''', '''''', [rfReplaceAll])]));

    if CDS.RecordCount = 0 then
      raise Exception.Create('User not found in database');

    if CDS.FieldByName('Status').AsInteger <> 1 then
      raise Exception.Create('Account has been disabled');

    FCurrentUser.UserID := CDS.FieldByName('UserID').AsInteger;
    FCurrentUser.UserName := CDS.FieldByName('UserName').AsString;
    FCurrentUser.RealName := CDS.FieldByName('RealName').AsString;
    FCurrentUser.Status := CDS.FieldByName('Status').AsInteger;
    FCurrentUser.IsSuperAdmin := CDS.FieldByName('IsSuperAdmin').AsInteger = 1;

    Result := True;
  finally
    CDS.Free;
  end;
end;

procedure TUser.Logout;
begin
  FTCPClient.Disconnect;
  FillChar(FCurrentUser, SizeOf(FCurrentUser), 0);
end;

function TUser.IsLoggedIn: Boolean;
begin
  Result := (FCurrentUser.UserID > 0) and FTCPClient.IsConnected;
end;

function TUser.LoadUsers: Boolean;
begin
  try
    FCDSUsers.OpenData('SELECT * FROM sys_Users ORDER BY UserID');
    Result := True;
  except
    Result := False;
  end;
end;

function TUser.GetUserByID(AUserID: Integer): TUserInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  if FCDSUsers.Active and FCDSUsers.Locate('UserID', AUserID, []) then
  begin
    Result.UserID := AUserID;
    Result.UserName := FCDSUsers.FieldByName('UserName').AsString;
    Result.RealName := FCDSUsers.FieldByName('RealName').AsString;
    Result.Status := FCDSUsers.FieldByName('Status').AsInteger;
    Result.IsSuperAdmin := FCDSUsers.FieldByName('IsSuperAdmin').AsInteger = 1;
  end;
end;

function TUser.SaveUser(const AUserInfo: TUserInfo): Boolean;
var
  PwdHash: string;
begin
  Result := False;
  if AUserInfo.UserID = 0 then
  begin
    PwdHash := HashPassword('123456');
    FCDSUsers.ExecCommand(Format(
      'INSERT INTO sys_Users (UserName, RealName, PasswordHash, Status, IsSuperAdmin) ' +
      'VALUES (''%s'', ''%s'', ''%s'', %d, %d)',
      [StringReplace(AUserInfo.UserName, '''', '''''', [rfReplaceAll]),
       StringReplace(AUserInfo.RealName, '''', '''''', [rfReplaceAll]),
       PwdHash, AUserInfo.Status, Ord(AUserInfo.IsSuperAdmin)]));
  end
  else
  begin
    FCDSUsers.ExecCommand(Format(
      'UPDATE sys_Users SET RealName = ''%s'', Status = %d ' +
      'WHERE UserID = %d',
      [StringReplace(AUserInfo.RealName, '''', '''''', [rfReplaceAll]),
       AUserInfo.Status, AUserInfo.UserID]));
  end;
  Result := True;
end;

function TUser.DeleteUser(AUserID: Integer): Boolean;
begin
  Result := False;
  if AUserID = SUPER_ADMIN_USER_ID then
    raise Exception.Create('Cannot delete super admin');
  FCDSUsers.ExecCommand(Format(
    'DELETE FROM sys_UserRole WHERE UserID = %d', [AUserID]));
  FCDSUsers.ExecCommand(Format(
    'DELETE FROM sys_Users WHERE UserID = %d', [AUserID]));
  Result := True;
end;

function TUser.ResetPassword(AUserID: Integer; const ANewPassword: string): Boolean;
var
  PwdHash: string;
begin
  if ANewPassword = '' then
    PwdHash := HashPassword('123456')
  else
    PwdHash := HashPassword(ANewPassword);

  FCDSUsers.ExecCommand(Format(
    'UPDATE sys_Users SET PasswordHash = ''%s'' WHERE UserID = %d',
    [PwdHash, AUserID]));
  Result := True;
end;

function TUser.ChangePassword(const AOldPwd, ANewPwd: string): Boolean;
var
  CDS: TAppClientDataSet;
begin
  Result := False;
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.OpenData(Format(
      'SELECT PasswordHash FROM sys_Users WHERE UserID = %d',
      [FCurrentUser.UserID]));

    if CDS.RecordCount = 0 then Exit;
    if not VerifyPassword(AOldPwd, CDS.FieldByName('PasswordHash').AsString) then
      Exit;

    FCDSUsers.ExecCommand(Format(
      'UPDATE sys_Users SET PasswordHash = ''%s'' WHERE UserID = %d',
      [HashPassword(ANewPwd), FCurrentUser.UserID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TUser.GetUsersDataSet: TDataSet;
begin
  LoadUsers;
  Result := FCDSUsers;
end;

end.
