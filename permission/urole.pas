unit urole;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  uappdefines, uapptypes, uappclientdataset, utcpclient;

type
  TRole = class
  private
    FTCPClient: TTCPClient;
    FCDSRoles: TAppClientDataSet;
    FCDSPermItems: TAppClientDataSet;
    FCDSRolePerms: TAppClientDataSet;
  public
    constructor Create(ATCPClient: TTCPClient);
    destructor Destroy; override;

    function LoadRoles: Boolean;
    function GetRoleByID(ARoleID: Integer): TRoleInfo;
    function GetRolesByUserID(AUserID: Integer): TArray<TRoleInfo>;
    function GetRolePermissions(ARoleID: Integer): TArray<TPermItem>;
    procedure GrantPermission(ARoleID: Integer; const APermCode: string;
      AIsGranted: Boolean);
    procedure RevokePermission(ARoleID: Integer; const APermCode: string);
    function SaveRole(const ARoleInfo: TRoleInfo): Boolean;
    function DeleteRole(ARoleID: Integer): Boolean;

    function GetRolesDataSet: TDataSet;
  end;

implementation

constructor TRole.Create(ATCPClient: TTCPClient);
begin
  inherited Create;
  FTCPClient := ATCPClient;
  FCDSRoles := TAppClientDataSet.Create(nil);
  FCDSRoles.AssignTCPClient(FTCPClient);
  FCDSPermItems := TAppClientDataSet.Create(nil);
  FCDSPermItems.AssignTCPClient(FTCPClient);
  FCDSRolePerms := TAppClientDataSet.Create(nil);
  FCDSRolePerms.AssignTCPClient(FTCPClient);
end;

destructor TRole.Destroy;
begin
  FCDSRoles.Free;
  FCDSPermItems.Free;
  FCDSRolePerms.Free;
  inherited;
end;

function TRole.LoadRoles: Boolean;
begin
  try
    FCDSRoles.OpenData('SELECT RoleID, RoleName, Remark FROM sys_Roles ORDER BY RoleID');
    Result := True;
  except
    Result := False;
  end;
end;

function TRole.GetRoleByID(ARoleID: Integer): TRoleInfo;
begin
  FillChar(Result, SizeOf(Result), 0);
  if FCDSRoles.Active and FCDSRoles.Locate('RoleID', ARoleID, []) then
  begin
    Result.RoleID := ARoleID;
    Result.RoleName := FCDSRoles.FieldByName('RoleName').AsString;
    Result.Remark := FCDSRoles.FieldByName('Remark').AsString;
  end;
end;

function TRole.GetRolesByUserID(AUserID: Integer): TArray<TRoleInfo>;
var
  CDS: TAppClientDataSet;
  List: TList<TRoleInfo>;
  Info: TRoleInfo;
begin
  SetLength(Result, 0);
  List := TList<TRoleInfo>.Create;
  try
    CDS := TAppClientDataSet.Create(nil);
    try
      CDS.AssignTCPClient(FTCPClient);
      CDS.OpenData(Format(
        'SELECT r.RoleID, r.RoleName, r.Remark FROM sys_Roles r ' +
        'INNER JOIN sys_UserRole ur ON r.RoleID = ur.RoleID ' +
        'WHERE ur.UserID = %d', [AUserID]));

      CDS.First;
      while not CDS.Eof do
      begin
        Info.RoleID := CDS.FieldByName('RoleID').AsInteger;
        Info.RoleName := CDS.FieldByName('RoleName').AsString;
        Info.Remark := CDS.FieldByName('Remark').AsString;
        List.Add(Info);
        CDS.Next;
      end;
    finally
      CDS.Free;
    end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

function TRole.GetRolePermissions(ARoleID: Integer): TArray<TPermItem>;
var
  CDS: TAppClientDataSet;
  List: TList<TPermItem>;
  Item: TPermItem;
begin
  SetLength(Result, 0);
  List := TList<TPermItem>.Create;
  try
    CDS := TAppClientDataSet.Create(nil);
    try
      CDS.AssignTCPClient(FTCPClient);
      CDS.TableName := 'sys_PermItems';
      CDS.OpenData(Format(
        'SELECT pi.*, ' +
        'CASE WHEN rp.PermID IS NOT NULL THEN 1 ELSE 0 END AS IsGranted ' +
        'FROM sys_PermItems pi ' +
        'LEFT JOIN sys_RolePerm rp ON pi.PermID = rp.PermID AND rp.RoleID = %d ' +
        'ORDER BY pi.ModuleName, pi.PermID', [ARoleID]));

      CDS.First;
      while not CDS.Eof do
      begin
        Item.PermID := CDS.FieldByName('PermID').AsInteger;
        Item.ModuleName := CDS.FieldByName('ModuleName').AsString;
        Item.CompName := CDS.FieldByName('CompName').AsString;
        Item.CompCaption := CDS.FieldByName('CompCaption').AsString;
        Item.PermCode := CDS.FieldByName('PermCode').AsString;
        Item.IsGranted := CDS.FieldByName('IsGranted').AsInteger = 1;
        Item.IsActive := CDS.FieldByName('IsActive').AsInteger = 1;
        List.Add(Item);
        CDS.Next;
      end;
    finally
      CDS.Free;
    end;
    Result := List.ToArray;
  finally
    List.Free;
  end;
end;

procedure TRole.GrantPermission(ARoleID: Integer; const APermCode: string;
  AIsGranted: Boolean);
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);

    // check if exists
    CDS.OpenData(Format(
      'SELECT COUNT(*) AS CNT FROM sys_RolePerm rp ' +
      'INNER JOIN sys_PermItems pi ON rp.PermID = pi.PermID ' +
      'WHERE rp.RoleID = %d AND pi.PermCode = ''%s''',
      [ARoleID, StringReplace(APermCode, '''', '''''', [rfReplaceAll])]));

    if CDS.FieldByName('CNT').AsInteger > 0 then
    begin
      if AIsGranted then
        CDS.ExecCommand(Format(
          'UPDATE rp SET IsGranted = 1 FROM sys_RolePerm rp ' +
          'INNER JOIN sys_PermItems pi ON rp.PermID = pi.PermID ' +
          'WHERE rp.RoleID = %d AND pi.PermCode = ''%s''',
          [ARoleID, StringReplace(APermCode, '''', '''''', [rfReplaceAll])]))
      else
        RevokePermission(ARoleID, APermCode);
    end
    else
    begin
      if AIsGranted then
        CDS.ExecCommand(Format(
          'INSERT INTO sys_RolePerm (RoleID, PermID, IsGranted) ' +
          'SELECT %d, PermID, 1 FROM sys_PermItems WHERE PermCode = ''%s''',
          [ARoleID, StringReplace(APermCode, '''', '''''', [rfReplaceAll])]));
    end;
  finally
    CDS.Free;
  end;
end;

procedure TRole.RevokePermission(ARoleID: Integer; const APermCode: string);
var
  CDS: TAppClientDataSet;
begin
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format(
      'DELETE rp FROM sys_RolePerm rp ' +
      'INNER JOIN sys_PermItems pi ON rp.PermID = pi.PermID ' +
      'WHERE rp.RoleID = %d AND pi.PermCode = ''%s''',
      [ARoleID, StringReplace(APermCode, '''', '''''', [rfReplaceAll])]));
  finally
    CDS.Free;
  end;
end;

function TRole.SaveRole(const ARoleInfo: TRoleInfo): Boolean;
var
  CDS: TAppClientDataSet;
begin
  Result := False;
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    if ARoleInfo.RoleID = 0 then
    begin
      CDS.ExecCommand(Format(
        'INSERT INTO sys_Roles (RoleName, Remark) VALUES (''%s'', ''%s'')',
        [StringReplace(ARoleInfo.RoleName, '''', '''''', [rfReplaceAll]),
         StringReplace(ARoleInfo.Remark, '''', '''''', [rfReplaceAll])]));
    end
    else
    begin
      CDS.ExecCommand(Format(
        'UPDATE sys_Roles SET RoleName = ''%s'', Remark = ''%s'' WHERE RoleID = %d',
        [StringReplace(ARoleInfo.RoleName, '''', '''''', [rfReplaceAll]),
         StringReplace(ARoleInfo.Remark, '''', '''''', [rfReplaceAll]),
         ARoleInfo.RoleID]));
    end;
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TRole.DeleteRole(ARoleID: Integer): Boolean;
var
  CDS: TAppClientDataSet;
begin
  Result := False;
  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);
    CDS.ExecCommand(Format('DELETE FROM sys_UserRole WHERE RoleID = %d', [ARoleID]));
    CDS.ExecCommand(Format('DELETE FROM sys_RolePerm WHERE RoleID = %d', [ARoleID]));
    CDS.ExecCommand(Format('DELETE FROM sys_Roles WHERE RoleID = %d', [ARoleID]));
    Result := True;
  finally
    CDS.Free;
  end;
end;

function TRole.GetRolesDataSet: TDataSet;
begin
  LoadRoles;
  Result := FCDSRoles;
end;

end.
