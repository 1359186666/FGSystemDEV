unit ufrmusermgr;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uappclientdataset,
  ufrmbase, ufrmsingletablehelper;

type
  TUserMgrFrm = class(TFrmBase)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FHelper: TSingleTableHelper;
    procedure DoAdd(Sender: TObject);
    procedure DoEdit(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoRefresh(Sender: TObject);
  protected
    procedure DoCreate; override;
  public
    property Helper: TSingleTableHelper read FHelper;
  end;

implementation

{$R *.dfm}

procedure TUserMgrFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnAdd := DoAdd;
  FHelper.OnEdit := DoEdit;
  FHelper.OnDelete := DoDelete;
  FHelper.OnRefresh := DoRefresh;
  inherited;
end;

procedure TUserMgrFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TUserMgrFrm.DoCreate;
begin
  Caption := SUserMgrTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.SetPermissionManager(FPermissionMgr);
    FHelper.ApplyPermissions;
    FHelper.OpenData('SELECT UserID, UserName, RealName, Status FROM sys_Users');
  end;
end;

procedure TUserMgrFrm.DoAdd(Sender: TObject);
begin
  FHelper.MasterCDS.Append;
end;

procedure TUserMgrFrm.DoEdit(Sender: TObject);
begin
  FHelper.MasterCDS.Edit;
end;

procedure TUserMgrFrm.DoDelete(Sender: TObject);
begin
  if Application.MessageBox(PChar(STplConfirmDelete), PChar(Caption),
    MB_YESNO or MB_ICONQUESTION) = IDYES then
    FHelper.MasterCDS.Delete;
end;

procedure TUserMgrFrm.DoRefresh(Sender: TObject);
begin
  FHelper.OpenData('SELECT UserID, UserName, RealName, Status FROM sys_Users');
end;

end.
