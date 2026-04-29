unit ufrmbuttonconfig;

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
  TButtonConfigFrm = class(TFrmMultiTable)
    actSave: TAction;
    actAddBtn: TAction;
    actDeleteBtn: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actAddBtnExecute(Sender: TObject);
    procedure actDeleteBtnExecute(Sender: TObject);
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
  end;

implementation

{$R *.dfm}

procedure TButtonConfigFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  inherited;
end;

procedure TButtonConfigFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_ModuleConfig';
  cdsMaster.KeyFields := 'ID';
  cdsMaster.SQLText :=
    'SELECT ID, ModuleName, ModuleCaption ' +
    'FROM sys_ModuleConfig WHERE IsActive = 1 ORDER BY ModuleCaption';

  cdsDetail1.AssignTCPClient(FTCPClient);
  cdsDetail1.TableName := 'sys_ButtonConfig';
  cdsDetail1.KeyFields := 'ID';

  Caption := SConfigButtonTitle;
  inherited;
end;

procedure TButtonConfigFrm.DoApplyPermissions;
begin
  inherited;
  actSave.Visible := True;
  actAddBtn.Visible := True;
  actDeleteBtn.Visible := True;
end;

procedure TButtonConfigFrm.actSaveExecute(Sender: TObject);
begin
  if cdsDetail1.ChangeCount > 0 then
  begin
    cdsDetail1.ApplyToServer;
    Application.MessageBox(PChar('Button config saved'),
      PChar(Caption), MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure TButtonConfigFrm.actAddBtnExecute(Sender: TObject);
begin
  cdsDetail1.Append;
  cdsDetail1.FieldByName('ModuleID').AsInteger := cdsMaster.FieldByName('ID').AsInteger;
  cdsDetail1.FieldByName('ButtonName').AsString := '';
  cdsDetail1.FieldByName('ButtonCaption').AsString := '';
  cdsDetail1.FieldByName('ActionType').AsString := 'Custom';
  cdsDetail1.FieldByName('ToolbarGroup').AsString := 'Top';
  cdsDetail1.FieldByName('ImageIndex').AsInteger := 0;
  cdsDetail1.Post;
end;

procedure TButtonConfigFrm.actDeleteBtnExecute(Sender: TObject);
begin
  if cdsDetail1.IsEmpty then Exit;
  if Application.MessageBox(PChar('Delete selected button config?'),
    PChar(Caption), MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    cdsDetail1.Delete;
    cdsDetail1.ApplyToServer;
  end;
end;

end.
