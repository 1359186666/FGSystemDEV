unit uapptypes;

interface

uses
  System.Generics.Collections, uappdefines;

type
  TRowData = TDictionary<string, Variant>;

  TFieldDefInfo = record
    FieldName: string;
    DataType: string;
    Size: Integer;
    Required: Boolean;
  end;

  TChangeInfo = record
    Kind: string;           // Insert / Modify / Delete
    OldData: string;        // JSON
    Data: string;           // JSON
  end;

  TJSONResponse = record
    Success: Boolean;
    Message: string;
    TotalCount: Integer;
    RowsAffected: Integer;
    Meta: string;
    Rows: string;
    ReturnData: string;
  end;

  TPermItem = record
    PermID: Integer;
    ModuleName: string;
    CompName: string;
    CompCaption: string;
    PermCode: string;
    IsGranted: Boolean;
    IsActive: Boolean;
  end;

  TUserInfo = record
    UserID: Integer;
    UserName: string;
    RealName: string;
    PasswordHash: string;
    Status: Integer;
    IsSuperAdmin: Boolean;
  end;

  TRoleInfo = record
    RoleID: Integer;
    RoleName: string;
    Remark: string;
  end;

  TModuleConfig = record
    ID: Integer;
    ModuleName: string;
    ModuleCaption: string;
    ModuleCode: string;
    ParentMenuName: string;
    MenuIconIndex: Integer;
    SortOrder: Integer;
    IsActive: Boolean;
    ModuleType: TModuleType;
    AutoOpen: Boolean;
  end;

  TDataSetConfig = record
    ID: Integer;
    ModuleID: Integer;
    DatasetName: string;
    SQLText: string;
    KeyFields: string;
    DefaultOrderBy: string;
    PageSize: Integer;
    IsReadOnly: Boolean;
    MasterDatasetName: string;
    MasterKeyFields: string;
  end;

  TGridColumnConfig = record
    ID: Integer;
    DatasetConfigID: Integer;
    FieldName: string;
    ColumnCaption: string;
    ColumnIndex: Integer;
    ColumnWidth: Integer;
    Visible: Boolean;
    ReadOnly: Boolean;
    Alignment: string;
    DisplayFormat: string;
    IsLookup: Boolean;
    LookupDatasetID: Integer;
    LookupKeyField: string;
    LookupDisplayField: string;
    LookupListField: string;
    SummaryType: string;
    GroupIndex: Integer;
    SortOrder: string;
    Fixed: Boolean;
    BestFitMaxWidth: Boolean;
  end;

  TPanelControlConfig = record
    ID: Integer;
    ModuleID: Integer;
    DatasetName: string;
    PanelName: string;
    FieldName: string;
    ControlType: TControlType;
    Caption: string;
    Left: Integer;
    Top: Integer;
    Width: Integer;
    Height: Integer;
    TabOrder: Integer;
    FontSize: Integer;
    MaxLength: Integer;
    ReadOnly: Boolean;
    Required: Boolean;
    LookupDatasetID: Integer;
    LookupKeyField: string;
    LookupDisplayField: string;
    LookupListFields: string;
    Hint: string;
    DefaultValue: string;
    Visible: Boolean;
  end;

  TLookupConfig = record
    ID: Integer;
    LookupName: string;
    LookupCaption: string;
    SQLText: string;
    KeyField: string;
    DisplayField: string;
    ListFields: string;
    CacheExpireMin: Integer;
    IsTreeData: Boolean;
  end;

  TButtonConfig = record
    ID: Integer;
    ModuleID: Integer;
    ButtonName: string;
    ButtonCaption: string;
    ActionType: string;
    ToolbarGroup: string;
    ImageIndex: Integer;
    ShortCut: string;
    Hint: string;
  end;

  TModuleFullConfig = record
    Module: TModuleConfig;
    Datasets: TArray<TDataSetConfig>;
    GridColumns: TArray<TGridColumnConfig>;
    PanelControls: TArray<TPanelControlConfig>;
    Lookups: TArray<TLookupConfig>;
    Buttons: TArray<TButtonConfig>;
  end;

  PFlexFieldChangeInfo = ^TFlexFieldChangeInfo;
  TFlexFieldChangeInfo = record
    Kind: TFlexFieldChangeKind;
    FieldName: string;
    DataType: string;
    Size: Integer;
    Index: Integer;
  end;

implementation

end.
