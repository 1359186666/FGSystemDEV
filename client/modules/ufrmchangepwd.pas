unit ufrmchangepwd;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uuser, ulanguagemgr,
  ufrmbase;

type
  TChangePwdFrm = class(TFrmBase)
    pnlMain: TPanel;
    lblOldPwd: TLabel;
    edtOldPwd: TEdit;
    lblNewPwd: TLabel;
    edtNewPwd: TEdit;
    lblConfirmPwd: TLabel;
    edtConfirmPwd: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FSuccess: Boolean;
  protected
    procedure DoCreate; override;
  public
    property Success: Boolean read FSuccess;
  end;

implementation

{$R *.dfm}

procedure TChangePwdFrm.FormCreate(Sender: TObject);
begin
  inherited;
  FSuccess := False;
end;

procedure TChangePwdFrm.DoCreate;
begin
  inherited;
  DoLoadLanguage;
end;

procedure TChangePwdFrm.btnOKClick(Sender: TObject);
begin
  if Trim(edtOldPwd.Text) = '' then
  begin
    Application.MessageBox('Please enter current password', PChar(Caption),
      MB_OK or MB_ICONWARNING);
    edtOldPwd.SetFocus;
    Exit;
  end;

  if Trim(edtNewPwd.Text) = '' then
  begin
    Application.MessageBox('Please enter new password', PChar(Caption),
      MB_OK or MB_ICONWARNING);
    edtNewPwd.SetFocus;
    Exit;
  end;

  if Length(edtNewPwd.Text) < 6 then
  begin
    Application.MessageBox('Password must be at least 6 characters',
      PChar(Caption), MB_OK or MB_ICONWARNING);
    edtNewPwd.SetFocus;
    Exit;
  end;

  if edtNewPwd.Text <> edtConfirmPwd.Text then
  begin
    Application.MessageBox('Passwords do not match', PChar(Caption),
      MB_OK or MB_ICONWARNING);
    edtConfirmPwd.SetFocus;
    Exit;
  end;

  Cursor := crHourGlass;
  try
    try
      if FUser.ChangePassword(edtOldPwd.Text, edtNewPwd.Text) then
      begin
        Application.MessageBox('Password changed successfully',
          PChar(Caption), MB_OK or MB_ICONINFORMATION);
        FSuccess := True;
        Close;
      end
      else
      begin
        Application.MessageBox('Current password is incorrect',
          PChar(Caption), MB_OK or MB_ICONERROR);
        edtOldPwd.SetFocus;
      end;
    except
      on E: Exception do
        Application.MessageBox(PChar(E.Message), PChar(Caption),
          MB_OK or MB_ICONERROR);
    end;
  finally
    Cursor := crDefault;
  end;
end;

procedure TChangePwdFrm.btnCancelClick(Sender: TObject);
begin
  FSuccess := False;
  Close;
end;

end.
