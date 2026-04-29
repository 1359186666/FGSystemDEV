unit ufrmlookupconfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB,
  uappdefines, uapptypes, uapputils,
  utcpclient, uappclientdataset, uconfigmanager,
  ufrmbase, ufrmsingletable;

type
  TLookupConfigFrm = class(TFrmSingleTable)
    procedure FormCreate(Sender: TObject);
  protected
    procedure DoCreate; override;
  end;

implementation

{$R *.dfm}

procedure TLookupConfigFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  inherited;
end;

procedure TLookupConfigFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_LookupConfig';
  cdsMaster.KeyFields := 'ID';
  cdsMaster.SQLText := 'SELECT * FROM sys_LookupConfig ORDER BY LookupName';
  inherited;
end;

end.
