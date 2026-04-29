unit ulanguagemgr;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IniFiles,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,
  Vcl.ActnList;

type
  TLanguageManager = class
  private
    FCurrentLang: string;
    FLangPath: string;
    FCache: TDictionary<string, TMemIniFile>;
    function LoadIniFileUTF8(const AFileName: string): TMemIniFile;
    procedure SaveIniFileUTF8(AIni: TMemIniFile; const AFileName: string);
  public
    constructor Create(const ALangPath: string);
    destructor Destroy; override;

    procedure SetLanguage(const ALangCode: string);
    function GetCurrentLanguage: string;
    function GetAvailableLanguages: TStringList;

    function GetString(const ASection, AKey, ADefault: string): string;
    procedure SetString(const ASection, AKey, AValue: string);
    procedure SaveCurrentLanguage;

    procedure TranslateForm(AForm: TForm; const ASectionName: string);
    procedure TranslateControl(AControl: TControl; const ASectionName: string);
    procedure LoadFormLanguage(AForm: TForm; const ASectionName: string);

    function CreateDefaultLanguageFile(const ALangCode: string): Boolean;
  end;

implementation

type
  THackControl = class(TControl)
  public
    property Caption;
  end;

constructor TLanguageManager.Create(const ALangPath: string);
begin
  inherited Create;
  FLangPath := ALangPath;
  if not FLangPath.EndsWith('\') then
    FLangPath := FLangPath + '\';
  FCurrentLang := 'zh-cn';
  FCache := TDictionary<string, TMemIniFile>.Create;
end;

destructor TLanguageManager.Destroy;
var
  Ini: TMemIniFile;
begin
  for Ini in FCache.Values do
    Ini.Free;
  FCache.Free;
  inherited;
end;

function TLanguageManager.LoadIniFileUTF8(const AFileName: string): TMemIniFile;
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    if FileExists(AFileName) then
    begin
      SL.LoadFromFile(AFileName, TEncoding.UTF8);
      Result := TMemIniFile.Create('');
      Result.SetStrings(SL);
    end
    else
    begin
      Result := TMemIniFile.Create('');
    end;
  finally
    SL.Free;
  end;
end;

procedure TLanguageManager.SaveIniFileUTF8(AIni: TMemIniFile; const AFileName: string);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    AIni.GetStrings(SL);
    ForceDirectories(ExtractFilePath(AFileName));
    SL.SaveToFile(AFileName, TEncoding.UTF8);
  finally
    SL.Free;
  end;
end;

procedure TLanguageManager.SetLanguage(const ALangCode: string);
var
  IniFile: string;
begin
  FCurrentLang := ALangCode;
  if not FCache.ContainsKey(ALangCode) then
  begin
    IniFile := FLangPath + ALangCode + '.ini';
    FCache.Add(ALangCode, LoadIniFileUTF8(IniFile));
  end;
end;

function TLanguageManager.GetCurrentLanguage: string;
begin
  Result := FCurrentLang;
end;

function TLanguageManager.GetAvailableLanguages: TStringList;
var
  SR: TSearchRec;
  LangCode: string;
begin
  Result := TStringList.Create;
  if FindFirst(FLangPath + '*.ini', faAnyFile, SR) = 0 then
  begin
    repeat
      LangCode := ChangeFileExt(SR.Name, '');
      Result.Add(LangCode);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
end;

function TLanguageManager.GetString(const ASection, AKey, ADefault: string): string;
var
  Ini: TMemIniFile;
begin
  if FCache.TryGetValue(FCurrentLang, Ini) then
    Result := Ini.ReadString(ASection, AKey, ADefault)
  else
    Result := ADefault;
end;

procedure TLanguageManager.SetString(const ASection, AKey, AValue: string);
var
  Ini: TMemIniFile;
begin
  if not FCache.TryGetValue(FCurrentLang, Ini) then
  begin
    Ini := TMemIniFile.Create('');
    FCache.AddOrSetValue(FCurrentLang, Ini);
  end;
  Ini.WriteString(ASection, AKey, AValue);
end;

procedure TLanguageManager.SaveCurrentLanguage;
var
  Ini: TMemIniFile;
  FileName: string;
begin
  if FCache.TryGetValue(FCurrentLang, Ini) then
  begin
    FileName := FLangPath + FCurrentLang + '.ini';
    SaveIniFileUTF8(Ini, FileName);
  end;
end;

procedure TLanguageManager.TranslateForm(AForm: TForm; const ASectionName: string);
var
  Ini: TMemIniFile;
  S, Section: string;
  procedure TranslateComponent(AComp: TComponent);
  var
    I: Integer;
    CtrlName: string;
    Child: TControl;
  begin
    if AComp.Name = '' then Exit;

    CtrlName := AComp.Name;

    // TAction
    if AComp is TAction then
    begin
      S := Ini.ReadString(ASectionName, CtrlName, '');
      if S <> '' then
      begin
        TAction(AComp).Caption := S;
        TAction(AComp).Hint := Ini.ReadString(ASectionName, CtrlName + '_Hint', S);
      end;
    end

    // TMenuItem
    else if AComp is TMenuItem then
    begin
      S := Ini.ReadString(ASectionName, CtrlName, '');
      if S <> '' then
        TMenuItem(AComp).Caption := S;
    end

    // TLabel
    else if AComp is TLabel then
    begin
      S := Ini.ReadString(ASectionName, CtrlName, '');
      if S <> '' then
        TLabel(AComp).Caption := S;
    end

    // TButton
    else if AComp is TButton then
    begin
      S := Ini.ReadString(ASectionName, CtrlName, '');
      if S <> '' then
        TButton(AComp).Caption := S;
    end

    // Form caption
    else if AComp is TForm then
    begin
      S := Ini.ReadString(ASectionName, 'Caption', '');
      if S <> '' then
        TForm(AComp).Caption := S;
    end

    // TTabSheet
    else if AComp is TTabSheet then
    begin
      S := Ini.ReadString(ASectionName, CtrlName, '');
      if S <> '' then
        TTabSheet(AComp).Caption := S;
    end

    // TGroupBox
    else if AComp is TGroupBox then
    begin
      S := Ini.ReadString(ASectionName, CtrlName, '');
      if S <> '' then
        TGroupBox(AComp).Caption := S;
    end;

    // recurse children
    if AComp is TWinControl then
    begin
      for I := 0 to TWinControl(AComp).ControlCount - 1 do
      begin
        Child := TWinControl(AComp).Controls[I];
        TranslateComponent(Child);
      end;
    end;
  end;

  procedure TranslateActions;
  var
    I: Integer;
  begin
    for I := 0 to AForm.ComponentCount - 1 do
    begin
      if AForm.Components[I] is TAction then
        TranslateComponent(AForm.Components[I]);
    end;
  end;

begin
  if not FCache.TryGetValue(FCurrentLang, Ini) then Exit;

  Section := ASectionName;
  if Section = '' then
  begin
    Section := AForm.ClassName;
    Section := StringReplace(Section, 'TFrm', '', []);
    Section := StringReplace(Section, 'TForm', '', []);
  end;

  TranslateActions;
  TranslateComponent(AForm);
end;

procedure TLanguageManager.TranslateControl(AControl: TControl;
  const ASectionName: string);
var
  Ini: TMemIniFile;
  S: string;
begin
  if not FCache.TryGetValue(FCurrentLang, Ini) then Exit;

  S := Ini.ReadString(ASectionName, AControl.Name, '');
  if S <> '' then
    THackControl(AControl).Caption := S;
end;

procedure TLanguageManager.LoadFormLanguage(AForm: TForm; const ASectionName: string);
begin
  TranslateForm(AForm, ASectionName);
end;

function TLanguageManager.CreateDefaultLanguageFile(const ALangCode: string): Boolean;
var
  Ini: TMemIniFile;
  FileName: string;
begin
  Result := False;
  FileName := FLangPath + ALangCode + '.ini';

  if FileExists(FileName) then Exit;

  Ini := TMemIniFile.Create('');
  try
    Ini.WriteString('LoginForm', 'Caption', 'User Login');
    Ini.WriteString('LoginForm', 'edtUser', 'User Name');
    Ini.WriteString('LoginForm', 'edtPwd', 'Password');
    Ini.WriteString('LoginForm', 'btnLogin', 'Login');
    Ini.WriteString('LoginForm', 'btnCancel', 'Cancel');

    Ini.WriteString('SingleTableTemplate', 'actAdd', 'Add');
    Ini.WriteString('SingleTableTemplate', 'actEdit', 'Edit');
    Ini.WriteString('SingleTableTemplate', 'actDelete', 'Delete');
    Ini.WriteString('SingleTableTemplate', 'actRefresh', 'Refresh');
    Ini.WriteString('SingleTableTemplate', 'actSearch', 'Search');
    Ini.WriteString('SingleTableTemplate', 'actExport', 'Export Excel');
    Ini.WriteString('SingleTableTemplate', 'actImport', 'Import Excel');
    Ini.WriteString('SingleTableTemplate', 'actPrint', 'Print');

    SaveIniFileUTF8(Ini, FileName);
    Result := True;
  finally
    Ini.Free;
  end;
end;

end.
