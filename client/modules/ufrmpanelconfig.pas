unit ufrmpanelconfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ActnList, Vcl.ToolWin,
  Data.DB,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, uconfigmanager,
  ufrmbase, ufrmmultitable;

type
  TPanelConfigFrm = class(TFrmMultiTable)
    actSave: TAction;
    actAddCtrl: TAction;
    actDeleteCtrl: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actAddCtrlExecute(Sender: TObject);
    procedure actDeleteCtrlExecute(Sender: TObject);
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
  end;

implementation

{$R *.dfm}

procedure TPanelConfigFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  inherited;
end;

procedure TPanelConfigFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_ModuleConfig';
  cdsMaster.KeyFields := 'ID';
  cdsMaster.SQLText :=
    'SELECT ID, ModuleName, ModuleCaption ' +
    'FROM sys_ModuleConfig WHERE IsActive = 1 ORDER BY ModuleCaption';

  cdsDetail1.AssignTCPClient(FTCPClient);
  cdsDetail1.TableName := 'sys_PanelControlConfig';
  cdsDetail1.KeyFields := 'ID';

  Caption := SConfigPanelTitle;
  inherited;
end;

procedure TPanelConfigFrm.DoApplyPermissions;
begin
  inherited;
  actSave.Visible := True;
  actAddCtrl.Visible := True;
  actDeleteCtrl.Visible := True;
end;

procedure TPanelConfigFrm.actSaveExecute(Sender: TObject);
begin
  if cdsDetail1.ChangeCount > 0 then
  begin
    cdsDetail1.ApplyToServer;
    Application.MessageBox(PChar('Panel control config saved'),
      PChar(Caption), MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure TPanelConfigFrm.actAddCtrlExecute(Sender: TObject);
begin
  cdsDetail1.Append;
  cdsDetail1.FieldByName('ModuleID').AsInteger := cdsMaster.FieldByName('ID').AsInteger;
  cdsDetail1.FieldByName('DatasetName').AsString := 'cdsMaster';
  cdsDetail1.FieldByName('PanelName').AsString := 'Panel1';
  cdsDetail1.FieldByName('FieldName').AsString := '';
  cdsDetail1.FieldByName('ControlType').AsString := 'ctDBEdit';
  cdsDetail1.FieldByName('Caption').AsString := '';
  cdsDetail1.FieldByName('Left').AsInteger := 10;
  cdsDetail1.FieldByName('Top').AsInteger := 10;
  cdsDetail1.FieldByName('Width').AsInteger := 200;
  cdsDetail1.FieldByName('Height').AsInteger := 22;
  cdsDetail1.FieldByName('TabOrder').AsInteger := 0;
  cdsDetail1.FieldByName('ReadOnly').AsInteger := 0;
  cdsDetail1.FieldByName('Required').AsInteger := 0;
  cdsDetail1.FieldByName('Visible').AsInteger := 1;
  cdsDetail1.Post;
end;

procedure TPanelConfigFrm.actDeleteCtrlExecute(Sender: TObject);
begin
  if cdsDetail1.IsEmpty then Exit;
  if Application.MessageBox(PChar('Delete selected control config?'),
    PChar(Caption), MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    cdsDetail1.Delete;
    cdsDetail1.ApplyToServer;
  end;
end;

end.
