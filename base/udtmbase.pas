unit udtmbase;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Datasnap.DBClient,
  uappdefines, utcpclient, uappclientdataset;

type
  TDtmBase = class(TDataModule)
  protected
    FTCPClient: TTCPClient;
    procedure DoCreate; virtual;
  public
    procedure SetTCPClient(AClient: TTCPClient);

    function CreateCDS: TAppClientDataSet;
    procedure FreeCDS(var ACDS: TAppClientDataSet);
  end;

implementation

{$R *.dfm}

procedure TDtmBase.SetTCPClient(AClient: TTCPClient);
begin
  FTCPClient := AClient;
end;

procedure TDtmBase.DoCreate;
begin
end;

function TDtmBase.CreateCDS: TAppClientDataSet;
begin
  Result := TAppClientDataSet.Create(Self);
  Result.AssignTCPClient(FTCPClient);
end;

procedure TDtmBase.FreeCDS(var ACDS: TAppClientDataSet);
begin
  if ACDS <> nil then
  begin
    ACDS.Free;
    ACDS := nil;
  end;
end;

end.
