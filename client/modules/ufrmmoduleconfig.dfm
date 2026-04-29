inherited ModuleConfigFrm: TFrmSingleTable
  Caption = 'Module Configuration'
  object pcConfig: TPageControl
    Left = 0
    Top = 334
    Width = 900
    Height = 197
    Align = alClient
    TabOrder = 0
    object tsModule: TTabSheet
      Caption = 'Module Info'
    end
    object tsDataSet: TTabSheet
      Caption = 'Datasets'
    end
    object tsGridColumns: TTabSheet
      Caption = 'Grid Columns'
    end
    object tsPanelControls: TTabSheet
      Caption = 'Panel Controls'
    end
    object tsButtons: TTabSheet
      Caption = 'Buttons'
    end
  end
  object actSaveConfig: TAction
    Caption = 'Save Config'
    OnExecute = actSaveConfigExecute
  end
  object actRefreshPerm: TAction
    Caption = 'Refresh Permissions'
    OnExecute = actRefreshPermExecute
  end
  object actPreviewModule: TAction
    Caption = 'Preview Module'
    OnExecute = actPreviewModuleExecute
  end
end
