unit userverinit;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IniFiles,
  Data.DB, Data.Win.ADODB,
  uappdefines, uapptypes;

type
  TServerInit = class
  private
    FADOConn: TADOConnection;
    FConnected: Boolean;
    FConfigFile: string;
    FLastError: string;
    procedure LoadConfig(var AServer, ADatabase, AUser, APassword: string;
      var APort: Integer);
    procedure SaveConfig(const AServer, ADatabase, AUser, APassword: string;
      APort: Integer);
    function BuildConnStr(const AServer, ADatabase, AUser, APassword: string;
      APort: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;

    function Connect(const AServer, ADatabase, AUser, APassword: string;
      APort: Integer = 0): Boolean; overload;
    function Connect: Boolean; overload;
    procedure Disconnect;
    function IsConnected: Boolean;
    function TestConnection(const AServer, ADatabase, AUser, APassword: string;
      APort: Integer = 0): Boolean;

    function CreateQuery: TADOQuery;
    function ExecSQL(const ASQL: string): Integer;
    function OpenSQL(const ASQL: string): TADOQuery;

    procedure Reconnect(const AServer, ADatabase, AUser, APassword: string;
      APort: Integer = 0);

    property ADOConnection: TADOConnection read FADOConn;
    property ConfigFile: string read FConfigFile write FConfigFile;
    property LastError: string read FLastError;
  end;

implementation

constructor TServerInit.Create;
begin
  inherited;
  FADOConn := TADOConnection.Create(nil);
  FADOConn.LoginPrompt := False;
  FADOConn.ConnectionTimeout := 10;
  FConnected := False;
  FConfigFile := ExtractFilePath(ParamStr(0)) + 'server.ini';
end;

destructor TServerInit.Destroy;
begin
  if FConnected then
    Disconnect;
  FADOConn.Free;
  inherited;
end;

function TServerInit.BuildConnStr(const AServer, ADatabase, AUser,
  APassword: string; APort: Integer): string;
begin
  Result := Format(
    'Provider=SQLOLEDB.1;Password=%s;Persist Security Info=True;' +
    'User ID=%s;Initial Catalog=%s;Data Source=%s',
    [APassword, AUser, ADatabase, AServer]);
  if APort > 0 then
    Result := Result + ',' + IntToStr(APort);
end;

function TServerInit.Connect(const AServer, ADatabase, AUser,
  APassword: string; APort: Integer = 0): Boolean;
begin
  Result := False;
  FLastError := '';
  try
    FADOConn.Close;
    FADOConn.ConnectionString := BuildConnStr(AServer, ADatabase, AUser,
      APassword, APort);
    FADOConn.Open;
    FConnected := True;
    Result := True;
  except
    on E: Exception do
    begin
      FLastError := E.Message;
      FConnected := False;
    end;
  end;
end;

function TServerInit.Connect: Boolean;
var
  Server, DB, User, Pwd: string;
  Port: Integer;
begin
  Result := FConnected;
  if Result then Exit;

  LoadConfig(Server, DB, User, Pwd, Port);
  Result := Connect(Server, DB, User, Pwd, Port);
end;

procedure TServerInit.LoadConfig(var AServer, ADatabase, AUser, APassword: string;
  var APort: Integer);
var
  Ini: TMemIniFile;
begin
  AServer := '127.0.0.1';
  ADatabase := 'FrameworkDB';
  AUser := 'sa';
  APassword := '';
  APort := 0;

  if FileExists(FConfigFile) then
  begin
    Ini := TMemIniFile.Create(FConfigFile, TEncoding.UTF8);
    try
      AServer := Ini.ReadString('Database', 'Server', '127.0.0.1');
      ADatabase := Ini.ReadString('Database', 'Database', 'FrameworkDB');
      AUser := Ini.ReadString('Database', 'User_Name', 'sa');
      APassword := Ini.ReadString('Database', 'Password', '');
      APort := Ini.ReadInteger('Database', 'Port', 0);
    finally
      Ini.Free;
    end;
  end;
end;

procedure TServerInit.SaveConfig(const AServer, ADatabase, AUser, APassword: string;
  APort: Integer);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FConfigFile, TEncoding.UTF8);
  try
    Ini.WriteString('Database', 'Server', AServer);
    Ini.WriteString('Database', 'Database', ADatabase);
    Ini.WriteString('Database', 'User_Name', AUser);
    Ini.WriteString('Database', 'Password', APassword);
    if APort > 0 then
      Ini.WriteInteger('Database', 'Port', APort)
    else
      Ini.DeleteKey('Database', 'Port');
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TServerInit.Reconnect(const AServer, ADatabase, AUser, APassword: string;
  APort: Integer = 0);
begin
  if FConnected then
    Disconnect;
  SaveConfig(AServer, ADatabase, AUser, APassword, APort);
  Connect(AServer, ADatabase, AUser, APassword, APort);
end;

procedure TServerInit.Disconnect;
begin
  try
    if FConnected then
    begin
      FADOConn.Close;
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

function TServerInit.CreateQuery: TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := FADOConn;
end;

function TServerInit.ExecSQL(const ASQL: string): Integer;
var
  Q: TADOQuery;
begin
  Result := -1;
  if not FConnected then Exit;

  Q := CreateQuery;
  try
    Q.SQL.Text := ASQL;
    Result := Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TServerInit.OpenSQL(const ASQL: string): TADOQuery;
var
  Q: TADOQuery;
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
  APassword: string; APort: Integer = 0): Boolean;
var
  TempConn: TADOConnection;
begin
  Result := False;
  FLastError := '';
  TempConn := TADOConnection.Create(nil);
  try
    TempConn.LoginPrompt := False;
    TempConn.ConnectionTimeout := 5;
    TempConn.ConnectionString := BuildConnStr(AServer, ADatabase, AUser,
      APassword, APort);
    TempConn.Open;
    Result := True;
    TempConn.Close;
  except
    on E: Exception do
      FLastError := E.Message;
  end;
  TempConn.Free;
end;

end.
