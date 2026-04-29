object FrmSingleTable: TFrmSingleTable
  Left = 0
  Top = 0
  Caption = 'Single Table'
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
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 50
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
      object btnAdd: TToolButton
        Left = 0
        Top = 0
        Action = actAdd
      end
      object btnEdit: TToolButton
        Left = 23
        Top = 0
        Action = actEdit
      end
      object btnDelete: TToolButton
        Left = 46
        Top = 0
        Action = actDelete
      end
      object btnRefresh: TToolButton
        Left = 69
        Top = 0
        Action = actRefresh
      end
      object btnSearch: TToolButton
        Left = 92
        Top = 0
        Action = actSearch
      end
      object btnExport: TToolButton
        Left = 115
        Top = 0
        Action = actExport
      end
      object btnImport: TToolButton
        Left = 138
        Top = 0
        Action = actImport
      end
      object btnPrint: TToolButton
        Left = 161
        Top = 0
        Action = actPrint
      end
      object btnCopy: TToolButton
        Left = 184
        Top = 0
        Action = actCopy
      end
      object btnBatchDelete: TToolButton
        Left = 207
        Top = 0
        Action = actBatchDelete
      end
      object btnBatchAudit: TToolButton
        Left = 230
        Top = 0
        Action = actBatchAudit
      end
      object btnClose: TToolButton
        Left = 253
        Top = 0
        Caption = 'Close'
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 50
    Width = 900
    Height = 531
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object grdMain: TcxGrid
      Left = 0
      Top = 0
      Width = 900
      Height = 331
      Align = alClient
      TabOrder = 0
      object grdMainView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = dtsMain
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
        OnDblClick = grdMainViewDblClick
      end
      object grdMainLevel: TcxGridLevel
        GridView = grdMainView
      end
    end
    object Splitter1: TSplitter
      Left = 0
      Top = 331
      Width = 900
      Height = 3
      Cursor = crVSplit
      Align = alBottom
    end
    object pnlDetail: TPanel
      Left = 0
      Top = 334
      Width = 900
      Height = 197
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object gbxSearch: TGroupBox
        Left = 8
        Top = 8
        Width = 400
        Height = 60
        Caption = 'Search'
        TabOrder = 0
      end
    end
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 581
    Width = 900
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 100
      end>
  end
  object alActions: TActionList
    Left = 400
    Top = 8
    object actAdd: TAction
      Caption = 'Add'
      OnExecute = actAddExecute
    end
    object actEdit: TAction
      Caption = 'Edit'
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Caption = 'Delete'
      OnExecute = actDeleteExecute
    end
    object actRefresh: TAction
      Caption = 'Refresh'
      OnExecute = actRefreshExecute
    end
    object actSearch: TAction
      Caption = 'Search'
      OnExecute = actSearchExecute
    end
    object actReset: TAction
      Caption = 'Reset'
      OnExecute = actResetExecute
    end
    object actExport: TAction
      Caption = 'Export Excel'
      OnExecute = actExportExecute
    end
    object actImport: TAction
      Caption = 'Import Excel'
      OnExecute = actImportExecute
    end
    object actPrint: TAction
      Caption = 'Print'
      OnExecute = actPrintExecute
    end
    object actCopy: TAction
      Caption = 'Copy'
      OnExecute = actCopyExecute
    end
    object actBatchDelete: TAction
      Caption = 'Batch Delete'
      OnExecute = actBatchDeleteExecute
    end
    object actBatchAudit: TAction
      Caption = 'Batch Audit'
      OnExecute = actBatchAuditExecute
    end
    object actFirst: TAction
      Caption = 'First'
      OnExecute = actFirstExecute
    end
    object actPrior: TAction
      Caption = 'Prior'
      OnExecute = actPriorExecute
    end
    object actNext: TAction
      Caption = 'Next'
      OnExecute = actNextExecute
    end
    object actLast: TAction
      Caption = 'Last'
      OnExecute = actLastExecute
    end
  end
  object dtsMain: TDataSource
    Left = 496
    Top = 8
  end
  object cdsMaster: TAppClientDataSet
    Aggregates = <>
    Params = <>
    Left = 592
    Top = 8
  end
end
