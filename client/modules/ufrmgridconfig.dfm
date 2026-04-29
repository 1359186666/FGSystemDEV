inherited GridConfigFrm: TFrmMultiTable
  Caption = 'Grid Column Configuration'
  object actSave: TAction
    Caption = 'Save'
    OnExecute = actSaveExecute
  end
  object actAddCol: TAction
    Caption = 'Add Column'
    OnExecute = actAddColExecute
  end
  object actDeleteCol: TAction
    Caption = 'Delete Column'
    OnExecute = actDeleteColExecute
  end
  object actMoveUp: TAction
    Caption = 'Move Up'
    OnExecute = actMoveUpExecute
  end
  object actMoveDown: TAction
    Caption = 'Move Down'
    OnExecute = actMoveDownExecute
  end
end
