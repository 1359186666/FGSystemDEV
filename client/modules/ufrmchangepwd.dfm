object ChangePwdFrm: TChangePwdFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 200
  ClientWidth = 380
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
    Width = 380
    Height = 200
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblOldPwd: TLabel
      Left = 40
      Top = 24
      Width = 100
      Height = 13
      Caption = 'Current Password:'
    end
    object edtOldPwd: TEdit
      Left = 150
      Top = 21
      Width = 180
      Height = 21
      PasswordChar = '*'
      TabOrder = 0
    end
    object lblNewPwd: TLabel
      Left = 40
      Top = 56
      Width = 100
      Height = 13
      Caption = 'New Password:'
    end
    object edtNewPwd: TEdit
      Left = 150
      Top = 53
      Width = 180
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
    object lblConfirmPwd: TLabel
      Left = 40
      Top = 88
      Width = 100
      Height = 13
      Caption = 'Confirm Password:'
    end
    object edtConfirmPwd: TEdit
      Left = 150
      Top = 85
      Width = 180
      Height = 21
      PasswordChar = '*'
      TabOrder = 2
    end
    object btnOK: TButton
      Left = 150
      Top = 130
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 3
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 255
      Top = 130
      Width = 75
      Height = 25
      Caption = 'Cancel'
      TabOrder = 4
      OnClick = btnCancelClick
    end
  end
end
