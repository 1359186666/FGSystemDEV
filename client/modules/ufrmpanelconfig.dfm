inherited PanelConfigFrm: TFrmMultiTable
  Caption = 'Panel Control Configuration'
  object actSave: TAction
    Caption = 'Save'
    OnExecute = actSaveExecute
  end
  object actAddCtrl: TAction
    Caption = 'Add Control'
    OnExecute = actAddCtrlExecute
  end
  object actDeleteCtrl: TAction
    Caption = 'Delete Control'
    OnExecute = actDeleteCtrlExecute
  end
end
