unit uappdefines;

interface

const
  // 服务端配置
  DEFAULT_SERVER_HOST = '127.0.0.1';
  DEFAULT_SERVER_PORT = 9090;
  TCP_SEND_TIMEOUT = 30000;
  TCP_READ_TIMEOUT = 30000;
  TCP_CONNECT_TIMEOUT = 10000;
  TCP_MAX_BUFFER_SIZE = 1048576;

  // 分页
  DEFAULT_PAGE_SIZE = 50;

  // JSON Action
  ACTION_OPENDATA        = 'OpenData';
  ACTION_EXECCOMMAND     = 'ExecCommand';
  ACTION_APPLYCHANGES    = 'ApplyChanges';
  ACTION_AUTH            = 'Auth';
  ACTION_GETLOOKUPDATA   = 'GetLookupData';

  // 权限代码常量
  PERM_CANVIEW    = 'CanView';
  PERM_CANADD     = 'CanAdd';
  PERM_CANEDIT    = 'CanEdit';
  PERM_CANDELETE  = 'CanDelete';
  PERM_CANAUDIT   = 'CanAudit';
  PERM_CANPRINT   = 'CanPrint';
  PERM_CANEXPORT  = 'CanExport';
  PERM_CANIMPORT  = 'CanImport';
  PERM_CANCOPY    = 'CanCopy';

  // 按钮ActionType
  BTN_ADD      = 'Add';
  BTN_EDIT     = 'Edit';
  BTN_DELETE   = 'Delete';
  BTN_REFRESH  = 'Refresh';
  BTN_SEARCH   = 'Search';
  BTN_RESET    = 'Reset';
  BTN_EXPORT   = 'Export';
  BTN_IMPORT   = 'Import';
  BTN_PRINT    = 'Print';
  BTN_COPY     = 'Copy';
  BTN_AUDIT    = 'Audit';
  BTN_CUSTOM   = 'Custom';

  // 默认语言
  DEFAULT_LANG = 'zh-cn';

  // 超级管理员角色ID
  SUPER_ADMIN_ROLE_ID = 1;
  SUPER_ADMIN_USER_ID = 1;

type
  TControlType = (
    ctDBEdit,
    ctDBMemo,
    ctDBCheckBox,
    ctDBComboBox,
    ctDBLookupCombo,
    ctDBDateEdit,
    ctDBSpinEdit,
    ctDBImage,
    ctDBHyperLink,
    ctDBRadioGroup,
    ctDBLabel,
    ctSeparator,
    ctGroupBox,
    ctPageControl
  );

  TPermActionType = (
    patCanView,
    patCanAdd,
    patCanEdit,
    patCanDelete,
    patCanAudit,
    patCanPrint,
    patCanExport,
    patCanImport,
    patCanCopy
  );

  TDataSetStatus = (
    dssBrowse,
    dssEdit,
    dssInsert,
    dssSearch
  );

  TModuleType = (mtSingleTable, mtMultiTable, mtReport, mtCustom);

  TFlexFieldChangeKind = (fckAdd, fckDelete, fckInsert);

implementation

end.
