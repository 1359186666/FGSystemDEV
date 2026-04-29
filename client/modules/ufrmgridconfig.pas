unit ufrmgridconfig;

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
  TGridConfigFrm = class(TFrmMultiTable)
    actSave: TAction;
    actAddCol: TAction;
    actDeleteCol: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actAddColExecute(Sender: TObject);
    procedure actDeleteColExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
  private
    function GetCurrentDataSetConfigID: Integer;
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
  end;

implementation

{$R *.dfm}

procedure TGridConfigFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  inherited;
end;

procedure TGridConfigFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_DataSetConfig';
  cdsMaster.KeyFields := 'ID';
  cdsMaster.SQLText :=
    'SELECT ds.ID, ds.DatasetName, mc.ModuleCaption ' +
    'FROM sys_DataSetConfig ds ' +
    'LEFT JOIN sys_ModuleConfig mc ON ds.ModuleID = mc.ID ' +
    'ORDER BY mc.ModuleCaption, ds.DatasetName';

  cdsDetail1.AssignTCPClient(FTCPClient);
  cdsDetail1.TableName := 'sys_GridColumnConfig';
  cdsDetail1.KeyFields := 'ID';

  Caption := SConfigGridTitle;
  inherited;
end;

procedure TGridConfigFrm.DoApplyPermissions;
begin
  inherited;
  actSave.Visible := True;
  actAddCol.Visible := True;
  actDeleteCol.Visible := True;
  actMoveUp.Visible := True;
  actMoveDown.Visible := True;
end;

function TGridConfigFrm.GetCurrentDataSetConfigID: Integer;
begin
  if cdsMaster.IsEmpty then
    Result := 0
  else
    Result := cdsMaster.FieldByName('ID').AsInteger;
end;

procedure TGridConfigFrm.actSaveExecute(Sender: TObject);
begin
  if cdsDetail1.ChangeCount > 0 then
  begin
    cdsDetail1.ApplyToServer;
    Application.MessageBox(PChar('Grid column config saved'),
      PChar(Caption), MB_OK or MB_ICONINFORMATION);
  end;
end;

procedure TGridConfigFrm.actAddColExecute(Sender: TObject);
begin
  cdsDetail1.Append;
  cdsDetail1.FieldByName('DatasetConfigID').AsInteger := GetCurrentDataSetConfigID;
  cdsDetail1.FieldByName('FieldName').AsString := '';
  cdsDetail1.FieldByName('ColumnCaption').AsString := '';
  cdsDetail1.FieldByName('ColumnIndex').AsInteger := 0;
  cdsDetail1.FieldByName('ColumnWidth').AsInteger := 100;
  cdsDetail1.FieldByName('Visible').AsInteger := 1;
  cdsDetail1.FieldByName('ReadOnly').AsInteger := 0;
  cdsDetail1.FieldByName('Alignment').AsString := 'left';
  cdsDetail1.FieldByName('IsLookup').AsInteger := 0;
  cdsDetail1.Post;
end;

procedure TGridConfigFrm.actDeleteColExecute(Sender: TObject);
begin
  if cdsDetail1.IsEmpty then Exit;
  if Application.MessageBox(PChar('Delete selected column config?'),
    PChar(Caption), MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    cdsDetail1.Delete;
    cdsDetail1.ApplyToServer;
  end;
end;

procedure TGridConfigFrm.actMoveUpExecute(Sender: TObject);
var
  CurIdx: Integer;
begin
  if cdsDetail1.IsEmpty or cdsDetail1.Bof then Exit;
  CurIdx := cdsDetail1.FieldByName('ColumnIndex').AsInteger;
  cdsDetail1.Edit;
  cdsDetail1.FieldByName('ColumnIndex').AsInteger := CurIdx - 1;
  cdsDetail1.Post;
end;

procedure TGridConfigFrm.actMoveDownExecute(Sender: TObject);
var
  CurIdx: Integer;
begin
  if cdsDetail1.IsEmpty then Exit;
  CurIdx := cdsDetail1.FieldByName('ColumnIndex').AsInteger;
  cdsDetail1.Edit;
  cdsDetail1.FieldByName('ColumnIndex').AsInteger := CurIdx + 1;
  cdsDetail1.Post;
end;

end.
