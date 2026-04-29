unit utcpclient;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  IdTCPClient, IdGlobal, IdIOHandler, IdIOHandlerStack, IdBaseComponent,
  IdComponent, IdTCPConnection,
  uappdefines, uapptypes, ujsonprotocol;

type
  TTCPClient = class
  private
    FTCPClient: TIdTCPClient;
    FSessionToken: string;
    FHost: string;
    FPort: Integer;
    FConnected: Boolean;
    FLastError: string;
    procedure SetHost(const Value: string);
    procedure SetPort(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    function Connect: Boolean;
    procedure Disconnect;

    function SendRequest(const AJSONRequest: string): string;

    function Login(const AUserName, APassword: string): Boolean;
    function IsConnected: Boolean;

    property Host: string read FHost write SetHost;
    property Port: Integer read FPort write SetPort;
    property SessionToken: string read FSessionToken;
    property Connected: Boolean read FConnected;
    property LastError: string read FLastError;
  end;

implementation

constructor TTCPClient.Create;
begin
  inherited;
  FTCPClient := TIdTCPClient.Create(nil);
  FTCPClient.ConnectTimeout := TCP_CONNECT_TIMEOUT;
  FTCPClient.ReadTimeout := TCP_READ_TIMEOUT;
  FSessionToken := '';
  FHost := DEFAULT_SERVER_HOST;
  FPort := DEFAULT_SERVER_PORT;
  FConnected := False;
end;

destructor TTCPClient.Destroy;
begin
  if FConnected then
    Disconnect;
  FTCPClient.Free;
  inherited;
end;

procedure TTCPClient.SetHost(const Value: string);
begin
  if Value <> FHost then
  begin
    if FConnected then
      Disconnect;
    FHost := Value;
  end;
end;

procedure TTCPClient.SetPort(const Value: Integer);
begin
  if Value <> FPort then
  begin
    if FConnected then
      Disconnect;
    FPort := Value;
  end;
end;

function TTCPClient.Connect: Boolean;
begin
  Result := False;
  if FConnected then Exit;

  try
    FTCPClient.Host := FHost;
    FTCPClient.Port := FPort;
    FTCPClient.Connect;
    FConnected := True;
    Result := True;
  except
    on E: Exception do
    begin
      FConnected := False;
    end;
  end;
end;

procedure TTCPClient.Disconnect;
begin
  try
    if FConnected then
    begin
      FTCPClient.Disconnect;
      FConnected := False;
    end;
  except
    FConnected := False;
  end;
end;

function TTCPClient.SendRequest(const AJSONRequest: string): string;
var
  RequestBytes: TIdBytes;
  ResponseStr: string;
begin
  Result := '';
  if not FConnected then
  begin
    if not Connect then
      Exit;
  end;

  try
    FTCPClient.IOHandler.WriteLn(AJSONRequest, IndyTextEncoding_UTF8);

    ResponseStr := Trim(FTCPClient.IOHandler.ReadLn(LF, IdTimeoutDefault, -1, IndyTextEncoding_UTF8));
    Result := ResponseStr;
  except
    on E: Exception do
    begin
      Result := '{"Success":false,"Message":"' +
        StringReplace(E.Message, '"', '\"', [rfReplaceAll]) + '"}';
    end;
  end;
end;

function TTCPClient.Login(const AUserName, APassword: string): Boolean;
var
  Req, Resp: string;
  JSONResp: TJSONResponse;
begin
  Result := False;
  FLastError := '';

  if not Connect then
  begin
    FLastError := 'Cannot connect to server ' + FHost + ':' + IntToStr(FPort);
    Exit;
  end;

  Req := TJSONProtocol.BuildAuthRequest(AUserName, APassword);
  Resp := SendRequest(Req);

  JSONResp := TJSONProtocol.ParseResponse(Resp);
  if JSONResp.Success then
  begin
    FSessionToken := JSONResp.Message;
    Result := True;
  end
  else
  begin
    FLastError := JSONResp.Message;
    if FLastError = '' then
      FLastError := 'Unknown server error';
  end;
end;

function TTCPClient.IsConnected: Boolean;
begin
  Result := FConnected;
end;

end.
