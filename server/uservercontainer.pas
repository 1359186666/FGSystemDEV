unit uservercontainer;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  IdContext,
  uappdefines, ujsonprotocol, utcpserver, userverinit, uservermethods;

type
  TServerContainer = class
  private
    FTCPServer: TTCPServer;
    FServerInit: TServerInit;
    FServerMethods: TServerMethods;
    procedure OnRequestReceived(const AContext: TIdContext;
      const ARequest: string; var AResponse: string);
    procedure OnClientConnected(const AContext: TIdContext);
    procedure OnClientDisconnected(const AContext: TIdContext);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Start(const APort: Integer = 0);
    procedure Stop;
    function IsRunning: Boolean;

    property ServerInit: TServerInit read FServerInit;
    property ServerMethods: TServerMethods read FServerMethods;
  end;

implementation

constructor TServerContainer.Create;
begin
  inherited;
  FTCPServer := TTCPServer.Create;
  FServerInit := TServerInit.Create;
end;

destructor TServerContainer.Destroy;
begin
  FTCPServer.Free;
  FServerInit.Free;
  FServerMethods.Free;
  inherited;
end;

procedure TServerContainer.Start(const APort: Integer = 0);
begin
  if not FServerInit.IsConnected then
    FServerInit.Connect;

  if FServerInit.IsConnected then
    FServerInit.InitDatabase;

  FServerMethods := TServerMethods.Create(FServerInit);

  FTCPServer.OnRequestReceived := OnRequestReceived;
  FTCPServer.OnClientConnect := OnClientConnected;
  FTCPServer.OnClientDisconnect := OnClientDisconnected;

  if APort > 0 then
    FTCPServer.Port := APort;

  FTCPServer.Start;
end;

procedure TServerContainer.Stop;
begin
  FTCPServer.Stop;
  FServerInit.Disconnect;
end;

function TServerContainer.IsRunning: Boolean;
begin
  Result := FTCPServer.Active;
end;

procedure TServerContainer.OnRequestReceived(const AContext: TIdContext;
  const ARequest: string; var AResponse: string);
begin
  try
    AResponse := FServerMethods.HandleRequest(ARequest);
  except
    on E: Exception do
    begin
      AResponse := Format('{"Success":false,"Message":"%s"}',
        [StringReplace(E.Message, '"', '\"', [rfReplaceAll])]);
    end;
  end;
end;

procedure TServerContainer.OnClientConnected(const AContext: TIdContext);
begin
end;

procedure TServerContainer.OnClientDisconnected(const AContext: TIdContext);
begin
end;

end.
