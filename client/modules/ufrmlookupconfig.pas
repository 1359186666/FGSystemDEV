unit ufrmlookupconfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Data.DB,
  uappdefines, uapptypes, uapputils,
  utcpclient, uappclientdataset,
  ufrmbase, ufrmsingletablehelper;

type
  TLookupConfigFrm = class(TFrmBase)
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
  end;

implementation

{$R *.dfm}

procedure TLookupConfigFrm.FormCreate(Sender: TObject);
begin
  FHelper := TSingleTableHelper.Create(Self);
  FHelper.OnAdd := DoAdd;
  FHelper.OnEdit := DoEdit;
  FHelper.OnDelete := DoDelete;
  FHelper.OnRefresh := DoRefresh;
  inherited;
end;

procedure TLookupConfigFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TLookupConfigFrm.DoCreate;
begin
  Caption := SConfigLookupTitle;
  if Assigned(FTCPClient) then
  begin
    FHelper.SetTCPClient(FTCPClient);
    FHelper.SetPermissionManager(FPermissionMgr);
    FHelper.ApplyPermissions;
    FHelper.OpenData('SELECT * FROM sys_LookupConfig');
  end;
end;

procedure TLookupConfigFrm.DoAdd(Sender: TObject);
begin FHelper.MasterCDS.Append; end;

procedure TLookupConfigFrm.DoEdit(Sender: TObject);
begin FHelper.MasterCDS.Edit; end;

procedure TLookupConfigFrm.DoDelete(Sender: TObject);
begin
  if Application.MessageBox(PChar(STplConfirmDelete), PChar(Caption), MB_YESNO or MB_ICONQUESTION) = IDYES then
    FHelper.MasterCDS.Delete;
end;

procedure TLookupConfigFrm.DoRefresh(Sender: TObject);
begin
  FHelper.OpenData('SELECT * FROM sys_LookupConfig');
end;

end.
