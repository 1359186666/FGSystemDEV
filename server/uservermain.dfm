object TServerMainFrm: TServerMainFrm
  Left = 0
  Top = 0
  Caption = 'Framework Server'
  ClientHeight = 498
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 784
    Height = 80
    Align = alTop
    TabOrder = 0
    object lblStatus: TLabel
      Left = 16
      Top = 12
      Width = 45
      Height = 13
      Caption = 'Stopped'
      Color = clRed
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object lblPort: TLabel
      Left = 160
      Top = 12
      Width = 26
      Height = 13
      Caption = 'Port:'
    end
    object btnStart: TButton
      Left = 16
      Top = 28
      Width = 75
      Height = 25
      Caption = 'Start'
      TabOrder = 0
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Left = 97
      Top = 28
      Width = 75
      Height = 25
      Caption = 'Stop'
      Enabled = False
      TabOrder = 1
      OnClick = btnStopClick
    end
    object edtPort: TEdit
      Left = 192
      Top = 9
      Width = 81
      Height = 21
      TabOrder = 2
      Text = '9090'
    end
    object btnConfig: TButton
      Left = 288
      Top = 7
      Width = 75
      Height = 25
      Caption = 'DB Config'
      TabOrder = 3
      OnClick = btnConfigClick
    end
    object btnTestDB: TButton
      Left = 368
      Top = 7
      Width = 85
      Height = 25
      Caption = 'Test DB'
      TabOrder = 4
      OnClick = btnTestDBClick
    end
    object lblDB: TLabel
      Left = 16
      Top = 56
      Width = 400
      Height = 13
      Caption = 'DB: Not configured'
    end
  end
  object mmLog: TMemo
    Left = 0
    Top = 57
    Width = 784
    Height = 441
    Align = alClient
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
