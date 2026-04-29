unit uappres;

interface

resourcestring
  SAppTitle = 'Enterprise Management System';
  SAppVersion = '1.0.0';

  SLoginCaption = 'User Login';
  SLoginUser = 'User Name';
  SLoginPwd = 'Password';
  SLoginBtnLogin = 'Login';
  SLoginBtnCancel = 'Cancel';
  SLoginRememberPwd = 'Remember Password';
  SLoginAutoLogin = 'Auto Login';
  SLoginServer = 'Server';
  SLoginPort = 'Port';
  SLoginLanguage = 'Language';
  SLoginFailure = 'Invalid username or password';
  SLoginConnecting = 'Connecting to server...';
  SLoginConnectFailed = 'Failed to connect to server';
  SLoginSuccess = 'Login successful';
  SLoginAccountDisabled = 'Account has been disabled';
  SLoginVersion = 'Version mismatch';

  SMainMenuFile = 'File';
  SMainMenuWindow = 'Window';
  SMainMenuHelp = 'Help';
  SMainMenuExit = 'Exit';
  SMainMenuCascade = 'Cascade';
  SMainMenuTileHorizontal = 'Horizontal Tile';
  SMainMenuTileVertical = 'Vertical Tile';
  SMainMenuCloseAll = 'Close All';
  SMainMenuAbout = 'About';
  SMainMenuAdmin = 'System Admin';
  SMainMenuPermission = 'Permissions';
  SMainMenuModuleConfig = 'Module Config';
  SMainMenuUserMgr = 'User Management';
  SMainMenuRoleMgr = 'Role Management';
  SMainMenuLangMgr = 'Language';
  SMainMenuChangePwd = 'Change Password';
  SMainStatusReady = 'Ready';
  SMainStatusOnline = 'Online';
  SMainStatusOffline = 'Offline';
  SMainToolbarAdmin = 'Admin';
  SMainToolbarLogout = 'Logout';

  STplBtnAdd = 'Add';
  STplBtnEdit = 'Edit';
  STplBtnDelete = 'Delete';
  STplBtnRefresh = 'Refresh';
  STplBtnSearch = 'Search';
  STplBtnReset = 'Reset';
  STplBtnExport = 'Export Excel';
  STplBtnImport = 'Import Excel';
  STplBtnPrint = 'Print';
  STplBtnCopy = 'Copy';
  STplBtnBatchDelete = 'Batch Delete';
  STplBtnBatchAudit = 'Batch Audit';
  STplBtnFirst = 'First';
  STplBtnPrior = 'Previous';
  STplBtnNext = 'Next';
  STplBtnLast = 'Last';
  STplConfirmDelete = 'Are you sure to delete?';
  STplConfirmBatchDelete = 'Are you sure to batch delete?';
  STplTitleAdd = 'Add';
  STplTitleEdit = 'Edit';
  STplTitleView = 'View';
  STplMsgSaveSuccess = 'Save succeeded';
  STplMsgSaveFailed = 'Save failed';
  STplMsgDeleteSuccess = 'Delete succeeded';
  STplMsgImportSuccess = 'Import succeeded, %d records';
  STplMsgImportFailed = 'Import failed';
  STplMsgExportSuccess = 'Export succeeded';
  STplMsgNoRecordSelected = 'Please select a record';
  STplMsgDataChanged = 'Data has been changed. Save?';
  STplStatusRecordCount = '%d records';
  STplStatusPageInfo = 'Page %d / %d';

  STplBtnAddMaster = 'Add Master';
  STplBtnAddDetail = 'Add Detail';
  STplBtnDeleteDetail = 'Delete Detail';
  STplTabDetail = 'Detail';

  SRptBtnPreview = 'Preview';
  SRptBtnPrint = 'Print';
  SRptBtnDesign = 'Design';
  SRptBtnExport = 'Export';
  SRptMsgPreview = 'Generating report preview...';
  SRptMsgPrint = 'Printing...';
  SRptMsgExport = 'Exporting report...';

  SConfigModuleTitle = 'Module Config';
  SConfigDataSetTitle = 'DataSet Config';
  SConfigGridTitle = 'Grid Column Config';
  SConfigPanelTitle = 'Panel Control Config';
  SConfigLookupTitle = 'Lookup Config';
  SConfigButtonTitle = 'Button Config';
  SConfigBtnSave = 'Save Config';
  SConfigBtnRefresh = 'Refresh Modules';
  SConfigBtnPreview = 'Preview';
  SConfigBtnAddModule = 'Add Module';
  SConfigBtnDeleteModule = 'Delete Module';
  SConfigBtnCopyModule = 'Copy Module';
  SConfigBtnConfirm = 'Confirm';
  SConfigBtnCancel = 'Cancel';
  SConfigMsgSaveSuccess = 'Config saved successfully';
  SConfigMsgConfirmDeleteModule = 'Delete module "%s"?';

  SPermTitle = 'Permission Management';
  SPermTabRolePerm = 'Role Permissions';
  SPermTabUserRole = 'User Roles';
  SPermBtnGrant = 'Grant';
  SPermBtnRevoke = 'Revoke';
  SPermBtnRefreshPerm = 'Refresh';
  SPermColModule = 'Module';
  SPermColPerm = 'Permission';
  SPermColGranted = 'Granted';
  SPermMsgRefreshOK = 'Permissions refreshed';

  SUserMgrTitle = 'User Management';
  SUserMgrColUserID = 'User ID';
  SUserMgrColUserName = 'User Name';
  SUserMgrColRealName = 'Name';
  SUserMgrColStatus = 'Status';
  SUserMgrColCreateTime = 'Create Time';
  SUserMgrStatusEnabled = 'Enabled';
  SUserMgrStatusDisabled = 'Disabled';
  SUserMgrPwdReset = 'Reset Password';
  SUserMgrBtnResetPwd = 'Reset Password';

  SRoleMgrTitle = 'Role Management';
  SRoleMgrColRoleID = 'Role ID';
  SRoleMgrColRoleName = 'Role Name';
  SRoleMgrColRemark = 'Remark';

  SValidateRequired = '"%s" is required';
  SValidateMaxLength = '"%s" cannot exceed %d characters';
  SValidateDuplicate = '"%s" already exists';

implementation

end.
