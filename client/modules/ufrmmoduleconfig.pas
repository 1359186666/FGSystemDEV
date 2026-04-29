unit ufrmmoduleconfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, uconfigmanager,
  ufrmbase, ufrmsingletablehelper;

type
  TModuleConfigFrm = class(TFrmBase)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FHelper: TSingleTableHelper;
    FpcConfig: TPageControl;
    procedure DoRefresh(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoSave(Sender: TObject);
  protected
    procedure DoCreate; override;
  end;

implementation

{$R *.dfm}

procedure TModuleConfigFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnRefresh := DoRefresh;
  FHelper.OnDelete := DoDelete;

  FpcConfig := TPageControl.Create(Self);
  FpcConfig.Parent := FHelper.DetailPanel;
  FpcConfig.Align := alClient;

  inherited;
end;

procedure TModuleConfigFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TModuleConfigFrm.DoCreate;
begin
  Caption := SConfigModuleTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.ApplyPermissions;
    FHelper.OpenData('SELECT * FROM sys_ModuleConfig');
  end;
end;

procedure TModuleConfigFrm.DoRefresh(Sender: TObject);
begin
  FHelper.OpenData('SELECT * FROM sys_ModuleConfig');
end;

procedure TModuleConfigFrm.DoDelete(Sender: TObject);
begin
  if Application.MessageBox(
    PChar(Format(SConfigMsgConfirmDeleteModule,
      [FHelper.MasterCDS.FieldByName('ModuleName').AsString])),
    PChar(Caption), MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    FHelper.MasterCDS.Delete;
    FHelper.MasterCDS.ApplyToServer;
  end;
end;

procedure TModuleConfigFrm.DoSave(Sender: TObject);
begin
  if Assigned(FConfigManager) then
    FConfigManager.RefreshCache;
end;

end.
