unit upermissionmgr;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.ActnList, Vcl.StdCtrls, Vcl.Menus,
  uapptypes, uappdefines, uappclientdataset, utcpclient, urole, uuser;

type
  TPermissionManager = class
  private
    FTCPClient: TTCPClient;
    FUser: TUser;
    FRole: TRole;
    FCachedPerms: TDictionary<string, Boolean>;
    FPermDataSet: TAppClientDataSet;
    procedure BuildPermDataSet;
  public
    constructor Create(ATCPClient: TTCPClient; AUser: TUser; ARole: TRole);
    destructor Destroy; override;

    // Permission check
    function HasPermission(const APermCode: string): Boolean;
    function HasAnyPermission(const APermCodes: array of string): Boolean;

    // Apply permissions to form
    procedure ApplyPermissions(AForm: TForm);

    // Refresh module permissions
    procedure RefreshModulePermissions(AForm: TForm);

    // Apply permissions to a specific control
    procedure ApplyToControl(AControl: TComponent; const APermCode: string);

    // Load from server
    procedure LoadUserPermissions;

    property PermDataSet: TAppClientDataSet read FPermDataSet;
  end;

implementation

constructor TPermissionManager.Create(ATCPClient: TTCPClient;
  AUser: TUser; ARole: TRole);
begin
  inherited Create;
  FTCPClient := ATCPClient;
  FUser := AUser;
  FRole := ARole;
  FCachedPerms := TDictionary<string, Boolean>.Create;
  FPermDataSet := TAppClientDataSet.Create(nil);
  FPermDataSet.AssignTCPClient(FTCPClient);
end;

destructor TPermissionManager.Destroy;
begin
  FCachedPerms.Free;
  FPermDataSet.Free;
  inherited;
end;

procedure TPermissionManager.BuildPermDataSet;
begin
  if FUser.CurrentUser.IsSuperAdmin then
  begin
    FPermDataSet.OpenData(
      'SELECT pi.*, 1 AS IsGranted ' +
      'FROM sys_PermItems pi ' +
      'WHERE pi.IsActive = 1 ' +
      'ORDER BY pi.ModuleName, pi.PermID');
  end
  else
  begin
    FPermDataSet.OpenData(Format(
      'SELECT pi.*, ' +
      'CASE WHEN rp.PermID IS NOT NULL AND rp.IsGranted = 1 THEN 1 ELSE 0 END AS IsGranted ' +
      'FROM sys_PermItems pi ' +
      'LEFT JOIN sys_RolePerm rp ON pi.PermID = rp.PermID ' +
      'LEFT JOIN sys_UserRole ur ON rp.RoleID = ur.RoleID ' +
      'WHERE ur.UserID = %d AND pi.IsActive = 1 ' +
      'GROUP BY pi.PermID, pi.ModuleName, pi.CompName, ' +
      'pi.CompCaption, pi.PermCode, pi.IsActive, pi.Remark, ' +
      'CASE WHEN rp.PermID IS NOT NULL AND rp.IsGranted = 1 THEN 1 ELSE 0 END ' +
      'ORDER BY pi.ModuleName, pi.PermID',
      [FUser.CurrentUser.UserID]));
  end;
end;

procedure TPermissionManager.LoadUserPermissions;
begin
  FCachedPerms.Clear;
  BuildPermDataSet;

  FPermDataSet.First;
  while not FPermDataSet.Eof do
  begin
    FCachedPerms.AddOrSetValue(
      FPermDataSet.FieldByName('PermCode').AsString,
      FPermDataSet.FieldByName('IsGranted').AsInteger = 1);
    FPermDataSet.Next;
  end;
end;

function TPermissionManager.HasPermission(const APermCode: string): Boolean;
begin
  if FUser.CurrentUser.IsSuperAdmin then
    Exit(True);

  FCachedPerms.TryGetValue(APermCode, Result);
end;

function TPermissionManager.HasAnyPermission(
  const APermCodes: array of string): Boolean;
var
  Code: string;
begin
  if FUser.CurrentUser.IsSuperAdmin then
    Exit(True);

  for Code in APermCodes do
  begin
    if HasPermission(Code) then
      Exit(True);
  end;
  Result := False;
end;

procedure TPermissionManager.ApplyToControl(AControl: TComponent;
  const APermCode: string);
var
  HasPerm: Boolean;
begin
  HasPerm := HasPermission(APermCode);

  if AControl is TAction then
    TAction(AControl).Visible := HasPerm
  else if AControl is TButton then
    TButton(AControl).Visible := HasPerm
  else if AControl is TMenuItem then
    TMenuItem(AControl).Visible := HasPerm
  else if AControl is TControl then
    TControl(AControl).Visible := HasPerm;
end;

procedure TPermissionManager.ApplyPermissions(AForm: TForm);
var
  I: Integer;
  Comp: TComponent;
  PermCode: string;
begin
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    Comp := AForm.Components[I];

    PermCode := '';
    if Comp is TAction then
      PermCode := TAction(Comp).Name
    else if Comp is TMenuItem then
      PermCode := TMenuItem(Comp).Name
    else if Comp is TButton then
      PermCode := TButton(Comp).Name;

    if PermCode <> '' then
    begin
      PermCode := StringReplace(PermCode, 'act', '', []);
      PermCode := StringReplace(PermCode, 'btn', '', []);
      PermCode := StringReplace(PermCode, 'mi', '', []);

      PermCode := AForm.ClassName;
      PermCode := StringReplace(PermCode, 'TFrm', '', []);
      PermCode := StringReplace(PermCode, 'TForm', '', []);
      PermCode := PermCode + '.' + StringReplace(PermCode, AForm.ClassName, '', []);

      ApplyToControl(Comp, PermCode);
    end;
  end;
end;

procedure TPermissionManager.RefreshModulePermissions(AForm: TForm);
var
  I: Integer;
  Comp: TComponent;
  CompName, CompCaption, PermCode, ModuleName: string;
  ActionType: TPermActionType;
  CDS: TAppClientDataSet;
begin
  ModuleName := AForm.ClassName;

  CDS := TAppClientDataSet.Create(nil);
  try
    CDS.AssignTCPClient(FTCPClient);

    // load existing permissions
    CDS.OpenData(Format(
      'SELECT * FROM sys_PermItems WHERE ModuleName = ''%s''',
      [ModuleName]));

    for I := 0 to AForm.ComponentCount - 1 do
    begin
      Comp := AForm.Components[I];

      if Comp is TAction then
      begin
        CompName := TAction(Comp).Name;
        CompCaption := TAction(Comp).Caption;
      end
      else if Comp is TButton then
      begin
        CompName := TButton(Comp).Name;
        CompCaption := TButton(Comp).Caption;
      end
      else
        Continue;

      // generate PermCode
      PermCode := ModuleName;
      PermCode := StringReplace(PermCode, 'TFrm', '', []);
      PermCode := StringReplace(PermCode, 'TForm', '', []);
      PermCode := PermCode + '.' + StringReplace(CompName, 'act', '', []);
      PermCode := StringReplace(PermCode, 'btn', '', []);

      // check if exists
      if not CDS.Locate('CompName', CompName, []) then
      begin
        CDS.ExecCommand(Format(
          'INSERT INTO sys_PermItems ' +
          '(ModuleName, CompName, CompCaption, PermCode, IsActive) ' +
          'VALUES (''%s'', ''%s'', ''%s'', ''%s'', 1)',
          [ModuleName, CompName,
           StringReplace(CompCaption, '''', '''''', [rfReplaceAll]),
           PermCode]));
      end
      else
      begin
        CDS.ExecCommand(Format(
          'UPDATE sys_PermItems SET IsActive = 1, CompCaption = ''%s'' ' +
          'WHERE ModuleName = ''%s'' AND CompName = ''%s''',
          [StringReplace(CompCaption, '''', '''''', [rfReplaceAll]),
           ModuleName, CompName]));
      end;
    end;

    // mark missing as inactive
    CDS.First;
    while not CDS.Eof do
    begin
      CompName := CDS.FieldByName('CompName').AsString;
      if AForm.FindComponent(CompName) = nil then
      begin
        CDS.ExecCommand(Format(
          'UPDATE sys_PermItems SET IsActive = 0 ' +
          'WHERE ModuleName = ''%s'' AND CompName = ''%s''',
          [ModuleName, CompName]));
      end;
      CDS.Next;
    end;
  finally
    CDS.Free;
  end;
end;

end.
