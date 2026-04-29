inherited PermissionMgrFrm: TFrmMultiTable
  Caption = 'Permission Management'
  object actGrant: TAction
    Caption = 'Grant All'
    OnExecute = actGrantExecute
  end
  object actRevoke: TAction
    Caption = 'Revoke All'
    OnExecute = actRevokeExecute
  end
  object actRefreshPermItems: TAction
    Caption = 'Refresh Permissions'
    OnExecute = actRefreshPermItemsExecute
  end
end
