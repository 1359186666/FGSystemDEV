unit utcpserver;

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  IdTCPServer, IdContext, IdGlobal, IdBaseComponent, IdComponent, IdCustomTCPServer,
  IdIOHandler, IdIOHandlerStack,
  uappdefines, uapputils, ujsonprotocol;

type
  TOnRequestReceived = procedure(const AContext: TIdContext;
    const ARequest: string; var AResponse: string) of object;

  TOnClientConnect = procedure(const AContext: TIdContext) of object;
  TOnClientDisconnect = procedure(const AContext: TIdContext) of object;

  TTCPServer = class
  private
    FServer: TIdTCPServer;
    FPort: Integer;
    FActive: Boolean;
    FOnRequestReceived: TOnRequestReceived;
    FOnClientConnect: TOnClientConnect;
    FOnClientDisconnect: TOnClientDisconnect;
    FActiveSessions: TDictionary<string, Integer>;
    procedure DoOnExecute(AContext: TIdContext);
    procedure DoOnConnect(AContext: TIdContext);
    procedure DoOnDisconnect(AContext: TIdContext);
    function ParseAction(const AJSON: string): string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    function IsActive: Boolean;

    property Port: Integer read FPort write FPort;
    property Active: Boolean read FActive;
    property OnRequestReceived: TOnRequestReceived read FOnRequestReceived
      write FOnRequestReceived;
    property OnClientConnect: TOnClientConnect read FOnClientConnect
      write FOnClientConnect;
    property OnClientDisconnect: TOnClientDisconnect read FOnClientDisconnect
      write FOnClientDisconnect;
  end;

implementation

constructor TTCPServer.Create;
begin
  inherited;
  FServer := TIdTCPServer.Create(nil);
  FServer.DefaultPort := DEFAULT_SERVER_PORT;
  FPort := DEFAULT_SERVER_PORT;
  FActive := False;
  FActiveSessions := TDictionary<string, Integer>.Create;

  FServer.OnExecute := DoOnExecute;
  FServer.OnConnect := DoOnConnect;
  FServer.OnDisconnect := DoOnDisconnect;
end;

destructor TTCPServer.Destroy;
begin
  if FActive then Stop;
  FServer.Free;
  FActiveSessions.Free;
  inherited;
end;

procedure TTCPServer.Start;
begin
  if FActive then Exit;
  FServer.Bindings.Clear;
  FServer.Bindings.Add.Port := FPort;
  FServer.DefaultPort := FPort;
  FServer.Active := True;
  FActive := True;
end;

procedure TTCPServer.Stop;
begin
  if not FActive then Exit;
  FServer.Active := False;
  FActive := False;
  FActiveSessions.Clear;
end;

function TTCPServer.IsActive: Boolean;
begin
  Result := FActive;
end;

function TTCPServer.ParseAction(const AJSON: string): string;
var
  JV: TJSONValue;
  JObj: TJSONObject;
begin
  Result := '';
  JV := TJSONObject.ParseJSONValue(AJSON);
  if JV = nil then Exit;

  if JV is TJSONObject then
  begin
    JObj := TJSONObject(JV);
    Result := SafeLoadStr(JObj, 'Action', '');
  end;
  JV.Free;
end;

procedure TTCPServer.DoOnExecute(AContext: TIdContext);
var
  RequestStr, ResponseStr: string;
begin
  try
    RequestStr := Trim(AContext.Connection.IOHandler.ReadLn(
      LF, IdTimeoutDefault, -1, IndyTextEncoding_UTF8));
    if RequestStr = '' then Exit;

    ResponseStr := '';
    if Assigned(FOnRequestReceived) then
    begin
      FOnRequestReceived(AContext, RequestStr, ResponseStr);
    end;

    if ResponseStr = '' then
      ResponseStr := '{"Success":false,"Message":"No handler for this request"}';

    AContext.Connection.IOHandler.WriteLn(ResponseStr, IndyTextEncoding_UTF8);
  except
    on E: Exception do
    begin
      try
        AContext.Connection.IOHandler.WriteLn(
          '{"Success":false,"Message":"Internal server error"}',
          IndyTextEncoding_UTF8);
      except
      end;
    end;
  end;
end;

procedure TTCPServer.DoOnConnect(AContext: TIdContext);
begin
  TMonitor.Enter(FActiveSessions);
  try
    FActiveSessions.AddOrSetValue(AContext.Binding.PeerIP, 0);
  finally
    TMonitor.Exit(FActiveSessions);
  end;

  if Assigned(FOnClientConnect) then
    FOnClientConnect(AContext);
end;

procedure TTCPServer.DoOnDisconnect(AContext: TIdContext);
begin
  TMonitor.Enter(FActiveSessions);
  try
    if FActiveSessions.ContainsKey(AContext.Binding.PeerIP) then
      FActiveSessions.Remove(AContext.Binding.PeerIP);
  finally
    TMonitor.Exit(FActiveSessions);
  end;

  if Assigned(FOnClientDisconnect) then
    FOnClientDisconnect(AContext);
end;

end.
