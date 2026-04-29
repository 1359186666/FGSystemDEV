inherited ButtonConfigFrm: TFrmMultiTable
  Caption = 'Button Configuration'
  object actSave: TAction
    Caption = 'Save'
    OnExecute = actSaveExecute
  end
  object actAddBtn: TAction
    Caption = 'Add Button'
    OnExecute = actAddBtnExecute
  end
  object actDeleteBtn: TAction
    Caption = 'Delete Button'
    OnExecute = actDeleteBtnExecute
  end
end
