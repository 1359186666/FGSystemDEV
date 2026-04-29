unit ufrmusermgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset, uuser, urole,
  ufrmbase, ufrmsingletable;

type
  TUserMgrFrm = class(TFrmSingleTable)
    procedure FormCreate(Sender: TObject);
  protected
    procedure DoCreate; override;
    procedure DoApplyPermissions; override;
  end;

implementation

{$R *.dfm}

procedure TUserMgrFrm.FormCreate(Sender: TObject);
begin
  FormStyle := fsMDIChild;
  inherited;
end;

procedure TUserMgrFrm.DoCreate;
begin
  cdsMaster.AssignTCPClient(FTCPClient);
  cdsMaster.TableName := 'sys_Users';
  cdsMaster.KeyFields := 'UserID';
  cdsMaster.SQLText :=
    'SELECT UserID, UserName, RealName, Status, ' +
    'CASE WHEN Status = 1 THEN ''Enabled'' ELSE ''Disabled'' END AS StatusText ' +
    'FROM sys_Users ORDER BY UserID';
  inherited;
end;

procedure TUserMgrFrm.DoApplyPermissions;
begin
  inherited;
  Caption := SUserMgrTitle;
end;

end.
