unit uloginfrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  IdTCPClient,
  uappdefines, uapptypes, uapputils, uappres,
  utcpclient, uuser, urole, upermissionmgr, ulanguagemgr;

type
  TLoginFrm = class(TForm)
    pnlMain: TPanel;
    lblTitle: TLabel;
    lblUser: TLabel;
    edtUser: TEdit;
    lblPwd: TLabel;
    edtPwd: TEdit;
    btnLogin: TButton;
    btnCancel: TButton;
    lblServer: TLabel;
    edtServer: TEdit;
    lblPort: TLabel;
    edtPort: TEdit;
    cbLanguage: TComboBox;
    lblLanguage: TLabel;
    chkRemember: TCheckBox;
    btnTestConn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnTestConnClick(Sender: TObject);
  private
    FTCPClient: TTCPClient;
    FUser: TUser;
    FRole: TRole;
    FPermissionMgr: TPermissionManager;
    FLanguageManager: TLanguageManager;
    FLoginSuccess: Boolean;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure InitLanguage;
    procedure DoLogin;
  public
    property TCPClient: TTCPClient read FTCPClient;
    property LoginUser: TUser read FUser;
    property LoginRole: TRole read FRole;
    property PermissionManager: TPermissionManager read FPermissionMgr;
    property LanguageManager: TLanguageManager read FLanguageManager;
    property LoginSuccess: Boolean read FLoginSuccess;
  end;

implementation

{$R *.dfm}

uses
  System.IniFiles;

procedure TLoginFrm.FormCreate(Sender: TObject);
begin
  FTCPClient := TTCPClient.Create;
  FUser := TUser.Create(FTCPClient);
  FRole := TRole.Create(FTCPClient);
  FPermissionMgr := TPermissionManager.Create(FTCPClient, FUser, FRole);
  FLanguageManager := TLanguageManager.Create('lang\');

  Caption := SLoginCaption;

  edtServer.Text := DEFAULT_SERVER_HOST;
  edtPort.Text := IntToStr(DEFAULT_SERVER_PORT);

  LoadSettings;
  InitLanguage;
end;

procedure TLoginFrm.FormDestroy(Sender: TObject);
begin
  FPermissionMgr.Free;
  FRole.Free;
  FUser.Free;
  FTCPClient.Free;
  FLanguageManager.Free;
end;

procedure TLoginFrm.InitLanguage;
var
  SR: TSearchRec;
  LangFile, LangCode: string;
begin
  cbLanguage.Items.Clear;
  if FindFirst(ExtractFilePath(Application.ExeName) + 'lang\*.ini', faAnyFile, SR) = 0 then
  begin
    repeat
      LangFile := SR.Name;
      LangCode := ChangeFileExt(LangFile, '');
      cbLanguage.Items.Add(LangCode);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  if cbLanguage.Items.Count = 0 then
  begin
    cbLanguage.Items.Add('zh-cn');
    cbLanguage.Items.Add('en-us');
  end;

  cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(DEFAULT_LANG);
  if cbLanguage.ItemIndex < 0 then
    cbLanguage.ItemIndex := 0;
end;

procedure TLoginFrm.LoadSettings;
var
  Ini: TMemIniFile;
  IniPath: string;
begin
  IniPath := ExtractFilePath(Application.ExeName) + 'config.ini';
  if FileExists(IniPath) then
  begin
    Ini := TMemIniFile.Create(IniPath, TEncoding.UTF8);
    try
      edtServer.Text := Ini.ReadString('Login', 'Server', DEFAULT_SERVER_HOST);
      edtPort.Text := Ini.ReadString('Login', 'Port', IntToStr(DEFAULT_SERVER_PORT));
      edtUser.Text := Ini.ReadString('Login', 'UserName', '');
      chkRemember.Checked := Ini.ReadBool('Login', 'RememberPwd', False);
      if chkRemember.Checked then
        edtPwd.Text := Ini.ReadString('Login', 'Password', '');
      cbLanguage.ItemIndex := cbLanguage.Items.IndexOf(
        Ini.ReadString('Login', 'Language', DEFAULT_LANG));
    finally
      Ini.Free;
    end;
  end;
end;

procedure TLoginFrm.SaveSettings;
var
  Ini: TMemIniFile;
  IniPath: string;
begin
  IniPath := ExtractFilePath(Application.ExeName) + 'config.ini';
  Ini := TMemIniFile.Create(IniPath, TEncoding.UTF8);
  try
    Ini.WriteString('Login', 'Server', edtServer.Text);
    Ini.WriteString('Login', 'Port', edtPort.Text);
    Ini.WriteString('Login', 'UserName', edtUser.Text);
    Ini.WriteBool('Login', 'RememberPwd', chkRemember.Checked);
    if chkRemember.Checked then
      Ini.WriteString('Login', 'Password', edtPwd.Text)
    else
      Ini.DeleteKey('Login', 'Password');
    if cbLanguage.ItemIndex >= 0 then
      Ini.WriteString('Login', 'Language', cbLanguage.Items[cbLanguage.ItemIndex]);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

procedure TLoginFrm.btnLoginClick(Sender: TObject);
begin
  DoLogin;
end;

procedure TLoginFrm.btnCancelClick(Sender: TObject);
begin
  FLoginSuccess := False;
  Close;
end;

procedure TLoginFrm.btnTestConnClick(Sender: TObject);
var
  TestClient: TIdTCPClient;
begin
  btnTestConn.Enabled := False;
  Cursor := crHourGlass;
  try
    TestClient := TIdTCPClient.Create(nil);
    try
      TestClient.Host := edtServer.Text;
      TestClient.Port := StrToIntDef(edtPort.Text, DEFAULT_SERVER_PORT);
      TestClient.ConnectTimeout := 3000;
      TestClient.ReadTimeout := 3000;
      TestClient.Connect;
      TestClient.Disconnect;
      Application.MessageBox(
        PChar(Format('Connection to %s:%s succeeded!', [edtServer.Text, edtPort.Text])),
        PChar(SLoginCaption), MB_OK or MB_ICONINFORMATION);
    finally
      TestClient.Free;
    end;
  except
    on E: Exception do
      Application.MessageBox(
        PChar(Format('Cannot connect to %s:%s'#13#10'%s',
          [edtServer.Text, edtPort.Text, E.Message])),
        PChar(SLoginCaption), MB_OK or MB_ICONERROR);
  end;
  Cursor := crDefault;
  btnTestConn.Enabled := True;
end;

procedure TLoginFrm.DoLogin;
begin
  if Trim(edtUser.Text) = '' then
  begin
    Application.MessageBox('Please enter user name', 'Login', MB_OK or MB_ICONWARNING);
    edtUser.SetFocus;
    Exit;
  end;

  if Trim(edtPwd.Text) = '' then
  begin
    Application.MessageBox('Please enter password', 'Login', MB_OK or MB_ICONWARNING);
    edtPwd.SetFocus;
    Exit;
  end;

  FTCPClient.Host := edtServer.Text;
  FTCPClient.Port := StrToIntDef(edtPort.Text, DEFAULT_SERVER_PORT);

  if cbLanguage.ItemIndex >= 0 then
    FLanguageManager.SetLanguage(cbLanguage.Items[cbLanguage.ItemIndex]);

  Cursor := crHourGlass;
  try
    FLoginSuccess := FUser.Login(edtUser.Text, edtPwd.Text);
    if FLoginSuccess then
    begin
      SaveSettings;
      FPermissionMgr.LoadUserPermissions;
      ModalResult := mrOk;
    end
    else
    begin
      if FTCPClient.LastError <> '' then
        Application.MessageBox(PChar(FTCPClient.LastError), PChar(SLoginCaption),
          MB_OK or MB_ICONERROR)
      else
        Application.MessageBox(PChar(SLoginFailure), PChar(SLoginCaption),
          MB_OK or MB_ICONERROR);
      edtPwd.SetFocus;
    end;
  finally
    Cursor := crDefault;
  end;
end;

end.
