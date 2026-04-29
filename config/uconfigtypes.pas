unit uconfigtypes;

interface

uses
  System.SysUtils, System.Generics.Collections,
  uapptypes, uappdefines;

type
  TModuleConfigData = class
  private
    FModule: TModuleConfig;
    FDatasets: TList<TDataSetConfig>;
    FGridColumns: TList<TGridColumnConfig>;
    FPanelControls: TList<TPanelControlConfig>;
    FLookups: TList<TLookupConfig>;
    FButtons: TList<TButtonConfig>;
  public
    constructor Create;
    destructor Destroy; override;

    property Module: TModuleConfig read FModule write FModule;
    property Datasets: TList<TDataSetConfig> read FDatasets;
    property GridColumns: TList<TGridColumnConfig> read FGridColumns;
    property PanelControls: TList<TPanelControlConfig> read FPanelControls;
    property Lookups: TList<TLookupConfig> read FLookups;
    property Buttons: TList<TButtonConfig> read FButtons;
  end;

implementation

constructor TModuleConfigData.Create;
begin
  inherited;
  FDatasets := TList<TDataSetConfig>.Create;
  FGridColumns := TList<TGridColumnConfig>.Create;
  FPanelControls := TList<TPanelControlConfig>.Create;
  FLookups := TList<TLookupConfig>.Create;
  FButtons := TList<TButtonConfig>.Create;
end;

destructor TModuleConfigData.Destroy;
begin
  FDatasets.Free;
  FGridColumns.Free;
  FPanelControls.Free;
  FLookups.Free;
  FButtons.Free;
  inherited;
end;

end.
