object ServerMonitorFrm: TServerMonitorFrm
  Left = 0
  Top = 0
  Caption = 'Server Monitor'
  ClientHeight = 400
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object tbActions: TToolBar
    Left = 0
    Top = 0
    Width = 700
    Height = 29
    Caption = 'tbActions'
    TabOrder = 0
    object btnRefresh: TToolButton
      Left = 0
      Top = 0
      Action = actRefresh
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 29
    Width = 700
    Height = 60
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object lblConnections: TLabel
      Left = 16
      Top = 8
      Width = 80
      Height = 13
      Caption = 'Connections: 0'
    end
    object lblDBStatus: TLabel
      Left = 16
      Top = 24
      Width = 80
      Height = 13
      Caption = 'Database: --'
    end
    object lblUptime: TLabel
      Left = 16
      Top = 40
      Width = 80
      Height = 13
      Caption = 'Uptime: --'
    end
  end
  object mmInfo: TMemo
    Left = 0
    Top = 89
    Width = 700
    Height = 311
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 96
  end
  object actRefresh: TAction
    Caption = 'Refresh'
    OnExecute = actRefreshExecute
  end
end
