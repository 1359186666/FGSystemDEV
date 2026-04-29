object FrmReport: TFrmReport
  Left = 0
  Top = 0
  Caption = 'Report'
  ClientHeight = 600
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object tbActions: TToolBar
      Left = 0
      Top = 0
      Width = 900
      Height = 29
      Caption = 'tbActions'
      TabOrder = 0
      object btnPrint: TToolButton
        Left = 0
        Top = 0
        Action = actPrint
      end
      object btnPreview: TToolButton
        Left = 23
        Top = 0
        Action = actPreview
      end
      object btnDesign: TToolButton
        Left = 46
        Top = 0
        Action = actDesign
      end
      object btnExportPDF: TToolButton
        Left = 69
        Top = 0
        Action = actExportPDF
      end
      object btnExportExcel: TToolButton
        Left = 92
        Top = 0
        Action = actExportExcel
      end
      object btnExportHTML: TToolButton
        Left = 115
        Top = 0
        Action = actExportHTML
      end
      object btnClose: TToolButton
        Left = 138
        Top = 0
        Caption = 'Close'
      end
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 33
    Width = 900
    Height = 567
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
  object frxPreview: TfrxPreview
    Left = 0
    Top = 33
    Width = 900
    Height = 567
    Align = alClient
  end
  object frxReport: TfrxReport
    Version = '5.0'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    Preview = frxPreview
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 0
    ReportOptions.LastChange = 0
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = ()
    Left = 48
    Top = 8
    object frxDBDataset: TfrxDBDataset
      UserName = 'frxDBDataset'
      CloseDataSource = False
      DataSource = dtsReport
      BCDToCurrency = False
      Left = 128
      Top = 8
    end
  end
  object alActions: TActionList
    Left = 288
    Top = 8
    object actPrint: TAction
      Caption = 'Print'
      OnExecute = actPrintExecute
    end
    object actPreview: TAction
      Caption = 'Preview'
      OnExecute = actPreviewExecute
    end
    object actDesign: TAction
      Caption = 'Design'
      OnExecute = actDesignExecute
    end
    object actExportPDF: TAction
      Caption = 'Export PDF'
      OnExecute = actExportPDFExecute
    end
    object actExportExcel: TAction
      Caption = 'Export Excel'
      OnExecute = actExportExcelExecute
    end
    object actExportHTML: TAction
      Caption = 'Export HTML'
      OnExecute = actExportHTMLExecute
    end
  end
  object dtsReport: TDataSource
    Left = 208
    Top = 8
  end
  object cdsReport: TAppClientDataSet
    Aggregates = <>
    Params = <>
    Left = 368
    Top = 8
  end
end
