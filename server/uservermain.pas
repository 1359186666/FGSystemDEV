unit uservermain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.IniFiles, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  uservercontainer, userverinit;

type
  TDBConfigFrm = class(TForm)
    lblServer: TLabel;
    edtServer: TEdit;
    lblDB: TLabel;
    edtDB: TEdit;
    lblUser: TLabel;
    edtUser: TEdit;
    lblPwd: TLabel;
    edtPwd: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  public
    Server: string;
    Database: string;
    UserName: string;
    Password: string;
  end;

  TServerMainFrm = class(TForm)
    mmLog: TMemo;
    pnlTop: TPanel;
    btnStart: TButton;
    btnStop: TButton;
    lblStatus: TLabel;
    lblPort: TLabel;
    edtPort: TEdit;
    btnConfig: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
  private
    FServerContainer: TServerContainer;
    procedure Log(const AMsg: string);
  public
  end;

implementation

{$R *.dfm}

uses
  uappdefines;

procedure TServerMainFrm.FormCreate(Sender: TObject);
begin
  Caption := 'Framework Server';
  FServerContainer := TServerContainer.Create;
  edtPort.Text := IntToStr(DEFAULT_SERVER_PORT);
  lblStatus.Caption := 'Stopped';
  btnStop.Enabled := False;
end;

procedure TServerMainFrm.FormDestroy(Sender: TObject);
begin
  if FServerContainer.IsRunning then
    FServerContainer.Stop;
  FServerContainer.Free;
end;

procedure TServerMainFrm.btnStartClick(Sender: TObject);
begin
  Log('Starting server on port ' + edtPort.Text + '...');
  try
    FServerContainer.Start(StrToIntDef(edtPort.Text, DEFAULT_SERVER_PORT));
    lblStatus.Caption := 'Running';
    lblStatus.Font.Color := clGreen;
    btnStart.Enabled := False;
    btnStop.Enabled := True;
    edtPort.Enabled := False;
    Log('Server started successfully.');
  except
    on E: Exception do
    begin
      Log('Failed to start: ' + E.Message);
    end;
  end;
end;

procedure TServerMainFrm.btnStopClick(Sender: TObject);
begin
  Log('Stopping server...');
  try
    FServerContainer.Stop;
    lblStatus.Caption := 'Stopped';
    lblStatus.Font.Color := clRed;
    btnStart.Enabled := True;
    btnStop.Enabled := False;
    edtPort.Enabled := True;
    Log('Server stopped.');
  except
    on E: Exception do
    begin
      Log('Failed to stop: ' + E.Message);
    end;
  end;
end;

procedure TServerMainFrm.btnConfigClick(Sender: TObject);
var
  Dlg: TDBConfigFrm;
  Ini: TMemIniFile;
  CfgFile: string;
begin
  Dlg := TDBConfigFrm.CreateNew(Self);
  try
    Dlg.Caption := 'Database Configuration';
    Dlg.BorderStyle := bsDialog;
    Dlg.ClientWidth := 380;
    Dlg.ClientHeight := 210;
    Dlg.Position := poScreenCenter;

    Dlg.lblServer := TLabel.Create(Dlg);
    Dlg.lblServer.Parent := Dlg;
    Dlg.lblServer.Caption := 'Server:';
    Dlg.lblServer.Left := 20;
    Dlg.lblServer.Top := 16;

    Dlg.edtServer := TEdit.Create(Dlg);
    Dlg.edtServer.Parent := Dlg;
    Dlg.edtServer.Left := 120;
    Dlg.edtServer.Top := 13;
    Dlg.edtServer.Width := 230;

    Dlg.lblDB := TLabel.Create(Dlg);
    Dlg.lblDB.Parent := Dlg;
    Dlg.lblDB.Caption := 'Database:';
    Dlg.lblDB.Left := 20;
    Dlg.lblDB.Top := 46;

    Dlg.edtDB := TEdit.Create(Dlg);
    Dlg.edtDB.Parent := Dlg;
    Dlg.edtDB.Left := 120;
    Dlg.edtDB.Top := 43;
    Dlg.edtDB.Width := 230;

    Dlg.lblUser := TLabel.Create(Dlg);
    Dlg.lblUser.Parent := Dlg;
    Dlg.lblUser.Caption := 'User:';
    Dlg.lblUser.Left := 20;
    Dlg.lblUser.Top := 76;

    Dlg.edtUser := TEdit.Create(Dlg);
    Dlg.edtUser.Parent := Dlg;
    Dlg.edtUser.Left := 120;
    Dlg.edtUser.Top := 73;
    Dlg.edtUser.Width := 230;

    Dlg.lblPwd := TLabel.Create(Dlg);
    Dlg.lblPwd.Parent := Dlg;
    Dlg.lblPwd.Caption := 'Password:';
    Dlg.lblPwd.Left := 20;
    Dlg.lblPwd.Top := 106;

    Dlg.edtPwd := TEdit.Create(Dlg);
    Dlg.edtPwd.Parent := Dlg;
    Dlg.edtPwd.Left := 120;
    Dlg.edtPwd.Top := 103;
    Dlg.edtPwd.Width := 230;
    Dlg.edtPwd.PasswordChar := '*';

    Dlg.btnOK := TButton.Create(Dlg);
    Dlg.btnOK.Parent := Dlg;
    Dlg.btnOK.Caption := 'OK';
    Dlg.btnOK.Left := 195;
    Dlg.btnOK.Top := 145;
    Dlg.btnOK.Width := 75;
    Dlg.btnOK.OnClick := Dlg.btnOKClick;

    Dlg.btnCancel := TButton.Create(Dlg);
    Dlg.btnCancel.Parent := Dlg;
    Dlg.btnCancel.Caption := 'Cancel';
    Dlg.btnCancel.Left := 275;
    Dlg.btnCancel.Top := 145;
    Dlg.btnCancel.Width := 75;
    Dlg.btnCancel.OnClick := Dlg.btnCancelClick;

    // load current config
    CfgFile := FServerContainer.ServerInit.ConfigFile;
    if FileExists(CfgFile) then
    begin
      Ini := TMemIniFile.Create(CfgFile, TEncoding.UTF8);
      try
        Dlg.edtServer.Text := Ini.ReadString('Database', 'Server', '127.0.0.1');
        Dlg.edtDB.Text := Ini.ReadString('Database', 'Database', 'FrameworkDB');
        Dlg.edtUser.Text := Ini.ReadString('Database', 'User_Name', 'sa');
        Dlg.edtPwd.Text := Ini.ReadString('Database', 'Password', '');
      finally
        Ini.Free;
      end;
    end;

    if Dlg.ShowModal = mrOk then
    begin
      Log('Reconnecting to database...');
      try
        FServerContainer.ServerInit.Reconnect(
          Dlg.edtServer.Text,
          Dlg.edtDB.Text,
          Dlg.edtUser.Text,
          Dlg.edtPwd.Text);
        Log('Database connection updated successfully.');
      except
        on E: Exception do
          Log('Connection failed: ' + E.Message);
      end;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TServerMainFrm.Log(const AMsg: string);
begin
  mmLog.Lines.Add(FormatDateTime('yyyy-MM-dd HH:mm:ss', Now) + ' ' + AMsg);
end;

{ TDBConfigFrm }

procedure TDBConfigFrm.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TDBConfigFrm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
