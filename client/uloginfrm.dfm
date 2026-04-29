object LoginFrm: TLoginFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'User Login'
  ClientHeight = 280
  ClientWidth = 460
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 460
    Height = 280
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitle: TLabel
      Left = 0
      Top = 20
      Width = 460
      Height = 24
      Alignment = taCenter
      AutoSize = False
      Caption = 'Enterprise Management System'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblServer: TLabel
      Left = 60
      Top = 65
      Width = 80
      Height = 13
      Caption = 'Server:'
    end
    object edtServer: TEdit
      Left = 150
      Top = 62
      Width = 150
      Height = 21
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object lblPort: TLabel
      Left = 310
      Top = 65
      Width = 30
      Height = 13
      Caption = 'Port:'
    end
    object edtPort: TEdit
      Left = 340
      Top = 62
      Width = 50
      Height = 21
      TabOrder = 1
      Text = '9090'
    end
    object lblUser: TLabel
      Left = 60
      Top = 100
      Width = 80
      Height = 13
      Caption = 'User Name:'
    end
    object edtUser: TEdit
      Left = 150
      Top = 97
      Width = 150
      Height = 21
      TabOrder = 2
    end
    object lblPwd: TLabel
      Left = 60
      Top = 130
      Width = 80
      Height = 13
      Caption = 'Password:'
    end
    object edtPwd: TEdit
      Left = 150
      Top = 127
      Width = 150
      Height = 21
      PasswordChar = '*'
      TabOrder = 3
    end
    object lblLanguage: TLabel
      Left = 60
      Top = 160
      Width = 80
      Height = 13
      Caption = 'Language:'
    end
    object cbLanguage: TComboBox
      Left = 150
      Top = 157
      Width = 150
      Height = 21
      Style = csDropDownList
      TabOrder = 4
    end
    object chkRemember: TCheckBox
      Left = 150
      Top = 190
      Width = 120
      Height = 17
      Caption = 'Remember Password'
      TabOrder = 5
    end
    object btnLogin: TButton
      Left = 150
      Top = 225
      Width = 75
      Height = 25
      Caption = 'Login'
      Default = True
      TabOrder = 6
      OnClick = btnLoginClick
    end
    object btnCancel: TButton
      Left = 240
      Top = 225
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 7
      OnClick = btnCancelClick
    end
    object btnTestConn: TButton
      Left = 320
      Top = 225
      Width = 80
      Height = 25
      Caption = 'Test Conn'
      TabOrder = 8
      OnClick = btnTestConnClick
    end
  end
end
