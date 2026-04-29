object FrmMultiTable: TFrmMultiTable
  Left = 0
  Top = 0
  Caption = 'Multi Table'
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
      object btnAddMaster: TToolButton
        Left = 0
        Top = 0
        Action = actAddMaster
      end
      object btnEditMaster: TToolButton
        Left = 23
        Top = 0
        Action = actEditMaster
      end
      object btnDeleteMaster: TToolButton
        Left = 46
        Top = 0
        Action = actDeleteMaster
      end
      object btnSep1: TToolButton
        Left = 69
        Top = 0
        Width = 8
      end
      object btnAddDetail: TToolButton
        Left = 77
        Top = 0
        Action = actAddDetail
      end
      object btnEditDetail: TToolButton
        Left = 100
        Top = 0
        Action = actEditDetail
      end
      object btnDeleteDetail: TToolButton
        Left = 123
        Top = 0
        Action = actDeleteDetail
      end
      object btnSep2: TToolButton
        Left = 146
        Top = 0
        Width = 8
      end
      object btnRefresh: TToolButton
        Left = 154
        Top = 0
        Action = actRefresh
      end
      object btnSearch: TToolButton
        Left = 177
        Top = 0
        Action = actSearch
      end
      object btnExport: TToolButton
        Left = 200
        Top = 0
        Action = actExport
      end
      object btnImport: TToolButton
        Left = 223
        Top = 0
        Action = actImport
      end
      object btnPrint: TToolButton
        Left = 246
        Top = 0
        Action = actPrint
      end
      object btnCopy: TToolButton
        Left = 269
        Top = 0
        Action = actCopy
      end
      object btnBatchDelete: TToolButton
        Left = 292
        Top = 0
        Action = actBatchDelete
      end
      object btnClose: TToolButton
        Left = 315
        Top = 0
        Caption = 'Close'
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 50
    Width = 900
    Height = 550
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object grdMaster: TcxGrid
      Left = 0
      Top = 0
      Width = 900
      Height = 250
      Align = alTop
      TabOrder = 0
      object grdMasterView: TcxGridDBTableView
        Navigator.Buttons.CustomButtons = <>
        DataController.DataSource = dtsMaster
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsSelection.CellSelect = False
        OptionsView.GroupByBox = False
      end
      object grdMasterLevel: TcxGridLevel
        GridView = grdMasterView
      end
    end
    object Splitter1: TSplitter
      Left = 0
      Top = 250
      Width = 900
      Height = 3
      Cursor = crVSplit
      Align = alTop
    end
    object pcDetail: TPageControl
      Left = 0
      Top = 253
      Width = 900
      Height = 297
      Align = alClient
      TabOrder = 1
      OnChange = pcDetailChange
      object tsDetail1: TTabSheet
        Caption = 'Detail 1'
        object grdDetail1: TcxGrid
          Left = 0
          Top = 0
          Width = 892
          Height = 269
          Align = alClient
          TabOrder = 0
          object grdDetail1View: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataSource = dtsDetail1
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.CellSelect = False
            OptionsView.GroupByBox = False
          end
          object grdDetail1Level: TcxGridLevel
            GridView = grdDetail1View
          end
        end
      end
      object tsDetail2: TTabSheet
        Caption = 'Detail 2'
        object grdDetail2: TcxGrid
          Left = 0
          Top = 0
          Width = 892
          Height = 269
          Align = alClient
          TabOrder = 0
          object grdDetail2View: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataSource = dtsDetail2
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.CellSelect = False
            OptionsView.GroupByBox = False
          end
          object grdDetail2Level: TcxGridLevel
            GridView = grdDetail2View
          end
        end
      end
      object tsDetail3: TTabSheet
        Caption = 'Detail 3'
        object grdDetail3: TcxGrid
          Left = 0
          Top = 0
          Width = 892
          Height = 269
          Align = alClient
          TabOrder = 0
          object grdDetail3View: TcxGridDBTableView
            Navigator.Buttons.CustomButtons = <>
            DataController.DataSource = dtsDetail3
            DataController.Summary.DefaultGroupSummaryItems = <>
            DataController.Summary.FooterSummaryItems = <>
            DataController.Summary.SummaryGroups = <>
            OptionsSelection.CellSelect = False
            OptionsView.GroupByBox = False
          end
          object grdDetail3Level: TcxGridLevel
            GridView = grdDetail3View
          end
        end
      end
    end
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 581
    Width = 900
    Height = 19
    Panels = <>
  end
  object alActions: TActionList
    Left = 400
    Top = 8
    object actAddMaster: TAction
      Caption = 'Add Master'
      OnExecute = actAddMasterExecute
    end
    object actEditMaster: TAction
      Caption = 'Edit Master'
      OnExecute = actEditMasterExecute
    end
    object actDeleteMaster: TAction
      Caption = 'Delete Master'
      OnExecute = actDeleteMasterExecute
    end
    object actAddDetail: TAction
      Caption = 'Add Detail'
      OnExecute = actAddDetailExecute
    end
    object actEditDetail: TAction
      Caption = 'Edit Detail'
      OnExecute = actEditDetailExecute
    end
    object actDeleteDetail: TAction
      Caption = 'Delete Detail'
      OnExecute = actDeleteDetailExecute
    end
    object actRefresh: TAction
      Caption = 'Refresh'
      OnExecute = actRefreshExecute
    end
    object actSearch: TAction
      Caption = 'Search'
      OnExecute = actSearchExecute
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
  end
  object dtsMaster: TDataSource
    Left = 504
    Top = 8
  end
  object cdsMaster: TAppClientDataSet
    Aggregates = <>
    Params = <>
    Left = 600
    Top = 8
  end
  object dtsDetail1: TDataSource
    Left = 504
    Top = 56
  end
  object cdsDetail1: TAppClientDataSet
    Aggregates = <>
    Params = <>
    Left = 600
    Top = 56
  end
  object dtsDetail2: TDataSource
    Left = 504
    Top = 104
  end
  object cdsDetail2: TAppClientDataSet
    Aggregates = <>
    Params = <>
    Left = 600
    Top = 104
  end
  object dtsDetail3: TDataSource
    Left = 504
    Top = 152
  end
  object cdsDetail3: TAppClientDataSet
    Aggregates = <>
    Params = <>
    Left = 600
    Top = 152
  end
end
