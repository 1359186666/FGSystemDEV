unit userverinit;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IniFiles,
  Data.DB, Data.SqlExpr,
  uappdefines, uapptypes;

type
  TServerInit = class
  private
    FSQLConn: TSQLConnection;
    FConnected: Boolean;
    FConfigFile: string;
    procedure LoadConfig(var AServer, ADatabase, AUser, APassword: string);
    procedure SaveConfig(const AServer, ADatabase, AUser, APassword: string);
  public
    constructor Create;
    destructor Destroy; override;

    function Connect(const AServer, ADatabase, AUser, APassword: string): Boolean; overload;
    function Connect: Boolean; overload;
    procedure Disconnect;
    function IsConnected: Boolean;
    function TestConnection(const AServer, ADatabase, AUser, APassword: string): Boolean;

    function CreateQuery: TSQLQuery;
    function ExecSQL(const ASQL: string): Integer;
    function OpenSQL(const ASQL: string): TSQLQuery;

    procedure Reconnect(const AServer, ADatabase, AUser, APassword: string);

    property SQLConnection: TSQLConnection read FSQLConn;
    property ConfigFile: string read FConfigFile write FConfigFile;
  end;

implementation

constructor TServerInit.Create;
begin
  inherited;
  FSQLConn := TSQLConnection.Create(nil);
  FSQLConn.DriverName := 'MSSQL';
  FSQLConn.LibraryName := 'dbxmss.dll';
  FSQLConn.VendorLib := 'sqlncli11.dll';
  FConnected := False;
  FConfigFile := ExtractFilePath(ParamStr(0)) + 'server.ini';
end;

destructor TServerInit.Destroy;
begin
  if FConnected then
    Disconnect;
  FSQLConn.Free;
  inherited;
end;

function TServerInit.Connect(const AServer, ADatabase, AUser,
  APassword: string): Boolean;
begin
  Result := False;
  try
    FSQLConn.Params.Clear;
    FSQLConn.Params.Add('DriverName=MSSQL');
    FSQLConn.Params.Add('HostName=' + AServer);
    FSQLConn.Params.Add('Database=' + ADatabase);
    FSQLConn.Params.Add('User_Name=' + AUser);
    FSQLConn.Params.Add('Password=' + APassword);
    FSQLConn.Params.Add('BlobSize=-1');
    FSQLConn.Params.Add('ErrorResourceFile=');
    FSQLConn.Params.Add('LocaleCode=2052');
    FSQLConn.Params.Add('IsolationLevel=ReadCommitted');
    FSQLConn.Params.Add('OS Authentication=False');
    FSQLConn.Params.Add('Multiple Transactions=False');
    FSQLConn.Params.Add('Trim Char=False');

    FSQLConn.Open;
    FConnected := True;
    Result := True;
  except
    on E: Exception do
    begin
      FConnected := False;
    end;
  end;
end;

function TServerInit.Connect: Boolean;
var
  Server, DB, User, Pwd: string;
begin
  Result := FConnected;
  if Result then Exit;

  LoadConfig(Server, DB, User, Pwd);
  Result := Connect(Server, DB, User, Pwd);
end;

procedure TServerInit.LoadConfig(var AServer, ADatabase, AUser, APassword: string);
var
  Ini: TMemIniFile;
begin
  AServer := '127.0.0.1';
  ADatabase := 'FrameworkDB';
  AUser := 'sa';
  APassword := '';

  if FileExists(FConfigFile) then
  begin
    Ini := TMemIniFile.Create(FConfigFile, TEncoding.UTF8);
    try
      AServer := Ini.ReadString('Database', 'Server', '127.0.0.1');
      ADatabase := Ini.ReadString('Database', 'Database', 'FrameworkDB');
      AUser := Ini.ReadString('Database', 'User_Name', 'sa');
      APassword := Ini.ReadString('Database', 'Password', '');
    finally
      Ini.Free;
    end;
  end;
end;

procedure TServerInit.SaveConfig(const AServer, ADatabase, AUser, APassword: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FConfigFile, TEncoding.UTF8);
  try
    Ini.WriteString('Database', 'Server', AServer);
    Ini.WriteString('Database', 'Database', ADatabase);
    Ini.WriteString('Database', 'User_Name', AUser);
    Ini.WriteString('Database', 'Password', APassword);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TServerInit.Reconnect(const AServer, ADatabase, AUser, APassword: string);
begin
  if FConnected then
    Disconnect;
  SaveConfig(AServer, ADatabase, AUser, APassword);
  Connect(AServer, ADatabase, AUser, APassword);
end;

procedure TServerInit.Disconnect;
begin
  try
    if FConnected then
    begin
      FSQLConn.Close;
      FConnected := False;
    end;
  except
    FConnected := False;
  end;
end;

function TServerInit.IsConnected: Boolean;
begin
  Result := FConnected;
end;

function TServerInit.CreateQuery: TSQLQuery;
begin
  Result := TSQLQuery.Create(nil);
  Result.SQLConnection := FSQLConn;
end;

function TServerInit.ExecSQL(const ASQL: string): Integer;
var
  Q: TSQLQuery;
begin
  Result := -1;
  if not FConnected then Exit;

  Q := CreateQuery;
  try
    Q.SQL.Text := ASQL;
    Result := Q.ExecSQL(False);
  finally
    Q.Free;
  end;
end;

function TServerInit.OpenSQL(const ASQL: string): TSQLQuery;
var
  Q: TSQLQuery;
begin
  if not FConnected then
  begin
    Result := nil;
    Exit;
  end;

  Q := CreateQuery;
  try
    Q.SQL.Text := ASQL;
    Q.Open;
    Result := Q;
  except
    Q.Free;
    raise;
  end;
end;

function TServerInit.TestConnection(const AServer, ADatabase, AUser,
  APassword: string): Boolean;
var
  TempConn: TSQLConnection;
begin
  Result := False;
  TempConn := TSQLConnection.Create(nil);
  try
    TempConn.DriverName := 'MSSQL';
    TempConn.LibraryName := 'dbxmss.dll';
    TempConn.VendorLib := 'sqlncli11.dll';
    TempConn.Params.Add('DriverName=MSSQL');
    TempConn.Params.Add('HostName=' + AServer);
    TempConn.Params.Add('Database=' + ADatabase);
    TempConn.Params.Add('User_Name=' + AUser);
    TempConn.Params.Add('Password=' + APassword);
    TempConn.Open;
    Result := True;
    TempConn.Close;
  except
  end;
  TempConn.Free;
end;

end.
