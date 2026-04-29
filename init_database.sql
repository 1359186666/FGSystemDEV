-- ============================================================
-- Framework3Tier - SQL Server 2012 Database Initialization
-- ============================================================

-- 1. Create Database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FrameworkDB')
BEGIN
    CREATE DATABASE FrameworkDB;
END
GO

USE FrameworkDB;
GO

-- ============================================================
-- 2. System Tables
-- ============================================================

-- Users table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_Users') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_Users (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        UserName NVARCHAR(50) NOT NULL UNIQUE,
        RealName NVARCHAR(50) NOT NULL,
        PasswordHash NVARCHAR(256) NOT NULL,
        Status INT NOT NULL DEFAULT 1,
        IsSuperAdmin INT NOT NULL DEFAULT 0,
        CreateTime DATETIME NOT NULL DEFAULT GETDATE(),
        UpdateTime DATETIME NULL
    );
END
GO

-- Roles table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_Roles') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_Roles (
        RoleID INT IDENTITY(1,1) PRIMARY KEY,
        RoleName NVARCHAR(100) NOT NULL,
        Remark NVARCHAR(500) NULL,
        CreateTime DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- User-Role mapping
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_UserRole') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_UserRole (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        UserID INT NOT NULL,
        RoleID INT NOT NULL,
        CONSTRAINT FK_UserRole_User FOREIGN KEY (UserID) REFERENCES sys_Users(UserID) ON DELETE CASCADE,
        CONSTRAINT FK_UserRole_Role FOREIGN KEY (RoleID) REFERENCES sys_Roles(RoleID) ON DELETE CASCADE
    );
END
GO

-- Permission items
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_PermItems') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_PermItems (
        PermID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleName NVARCHAR(100) NOT NULL,
        CompName NVARCHAR(100) NOT NULL,
        CompCaption NVARCHAR(200) NULL,
        PermCode NVARCHAR(200) NOT NULL UNIQUE,
        IsActive INT NOT NULL DEFAULT 1,
        Remark NVARCHAR(500) NULL
    );
END
GO

-- Role-Permission mapping
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_RolePerm') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_RolePerm (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        RoleID INT NOT NULL,
        PermID INT NOT NULL,
        IsGranted INT NOT NULL DEFAULT 1,
        CONSTRAINT FK_RolePerm_Role FOREIGN KEY (RoleID) REFERENCES sys_Roles(RoleID) ON DELETE CASCADE,
        CONSTRAINT FK_RolePerm_Perm FOREIGN KEY (PermID) REFERENCES sys_PermItems(PermID) ON DELETE CASCADE
    );
END
GO

-- ============================================================
-- 3. Module Configuration Tables
-- ============================================================

-- Module config
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_ModuleConfig') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_ModuleConfig (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleName NVARCHAR(100) NOT NULL UNIQUE,
        ModuleCaption NVARCHAR(200) NULL,
        ModuleCode NVARCHAR(50) NULL,
        ParentMenuName NVARCHAR(200) NULL,
        MenuIconIndex INT NOT NULL DEFAULT 0,
        SortOrder INT NOT NULL DEFAULT 0,
        IsActive INT NOT NULL DEFAULT 1,
        Remark NVARCHAR(500) NULL
    );
END
GO

-- DataSet config
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_DataSetConfig') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_DataSetConfig (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleID INT NOT NULL,
        DatasetName NVARCHAR(50) NOT NULL,
        SQLText NVARCHAR(MAX) NULL,
        KeyFields NVARCHAR(200) NULL,
        DefaultOrderBy NVARCHAR(200) NULL,
        PageSize INT NOT NULL DEFAULT 0,
        IsReadOnly INT NOT NULL DEFAULT 0,
        MasterDatasetName NVARCHAR(50) NULL,
        MasterKeyFields NVARCHAR(200) NULL,
        BeforeOpenScript NVARCHAR(MAX) NULL,
        AfterOpenScript NVARCHAR(MAX) NULL,
        CONSTRAINT FK_DataSetConfig_Module FOREIGN KEY (ModuleID) REFERENCES sys_ModuleConfig(ID) ON DELETE CASCADE
    );
END
GO

-- Grid Column config
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_GridColumnConfig') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_GridColumnConfig (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        DatasetConfigID INT NOT NULL,
        FieldName NVARCHAR(100) NOT NULL,
        ColumnCaption NVARCHAR(200) NULL,
        ColumnIndex INT NOT NULL DEFAULT 0,
        ColumnWidth INT NOT NULL DEFAULT 100,
        Visible INT NOT NULL DEFAULT 1,
        ReadOnly INT NOT NULL DEFAULT 0,
        Alignment NVARCHAR(10) NULL DEFAULT 'left',
        DisplayFormat NVARCHAR(50) NULL,
        IsLookup INT NOT NULL DEFAULT 0,
        LookupDatasetID INT NULL,
        LookupKeyField NVARCHAR(100) NULL,
        LookupDisplayField NVARCHAR(100) NULL,
        LookupListField NVARCHAR(500) NULL,
        SummaryType NVARCHAR(50) NULL DEFAULT 'None',
        HeaderAlignment NVARCHAR(10) NULL,
        GroupIndex INT NOT NULL DEFAULT -1,
        SortOrder NVARCHAR(4) NULL,
        Fixed INT NOT NULL DEFAULT 0,
        BestFitMaxWidth INT NOT NULL DEFAULT 0,
        CONSTRAINT FK_GridColumn_DataSet FOREIGN KEY (DatasetConfigID) REFERENCES sys_DataSetConfig(ID) ON DELETE CASCADE
    );
END
GO

-- Panel Control config
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_PanelControlConfig') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_PanelControlConfig (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleID INT NOT NULL,
        DatasetName NVARCHAR(50) NULL,
        PanelName NVARCHAR(100) NULL,
        FieldName NVARCHAR(100) NULL,
        ControlType NVARCHAR(30) NOT NULL DEFAULT 'ctDBEdit',
        Caption NVARCHAR(200) NULL,
        [Left] INT NOT NULL DEFAULT 10,
        [Top] INT NOT NULL DEFAULT 10,
        Width INT NOT NULL DEFAULT 200,
        Height INT NOT NULL DEFAULT 22,
        TabOrder INT NOT NULL DEFAULT 0,
        FontSize INT NOT NULL DEFAULT 0,
        MaxLength INT NOT NULL DEFAULT 0,
        ReadOnly INT NOT NULL DEFAULT 0,
        Required INT NOT NULL DEFAULT 0,
        LookupDatasetID INT NULL,
        LookupKeyField NVARCHAR(100) NULL,
        LookupDisplayField NVARCHAR(100) NULL,
        LookupListFields NVARCHAR(500) NULL,
        Hint NVARCHAR(500) NULL,
        DefaultValue NVARCHAR(200) NULL,
        Visible INT NOT NULL DEFAULT 1,
        CONSTRAINT FK_PanelControl_Module FOREIGN KEY (ModuleID) REFERENCES sys_ModuleConfig(ID) ON DELETE CASCADE
    );
END
GO

-- Lookup config
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_LookupConfig') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_LookupConfig (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        LookupName NVARCHAR(100) NOT NULL,
        LookupCaption NVARCHAR(200) NULL,
        SQLText NVARCHAR(MAX) NULL,
        KeyField NVARCHAR(100) NOT NULL,
        DisplayField NVARCHAR(100) NOT NULL,
        ListFields NVARCHAR(500) NULL,
        CacheExpireMin INT NOT NULL DEFAULT 0,
        IsTreeData INT NOT NULL DEFAULT 0
    );
END
GO

-- Button config
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'sys_ButtonConfig') AND type in (N'U'))
BEGIN
    CREATE TABLE sys_ButtonConfig (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        ModuleID INT NOT NULL,
        ButtonName NVARCHAR(100) NOT NULL,
        ButtonCaption NVARCHAR(200) NULL,
        ActionType NVARCHAR(30) NOT NULL DEFAULT 'Custom',
        ToolbarGroup NVARCHAR(50) NULL DEFAULT 'Top',
        ImageIndex INT NOT NULL DEFAULT 0,
        ShortCut NVARCHAR(20) NULL,
        Hint NVARCHAR(500) NULL,
        CONSTRAINT FK_ButtonConfig_Module FOREIGN KEY (ModuleID) REFERENCES sys_ModuleConfig(ID) ON DELETE CASCADE
    );
END
GO

-- ============================================================
-- 4. Initial Data
-- ============================================================

-- Super admin role
IF NOT EXISTS (SELECT 1 FROM sys_Roles WHERE RoleID = 1)
BEGIN
    SET IDENTITY_INSERT sys_Roles ON;
    INSERT INTO sys_Roles (RoleID, RoleName, Remark)
    VALUES (1, N'超级管理员', N'系统超级管理员，拥有所有权限');
    SET IDENTITY_INSERT sys_Roles OFF;
END
GO

-- Admin role
IF NOT EXISTS (SELECT 1 FROM sys_Roles WHERE RoleName = N'管理员')
BEGIN
    INSERT INTO sys_Roles (RoleName, Remark)
    VALUES (N'管理员', N'系统管理员');
END
GO

-- Operator role
IF NOT EXISTS (SELECT 1 FROM sys_Roles WHERE RoleName = N'操作员')
BEGIN
    INSERT INTO sys_Roles (RoleName, Remark)
    VALUES (N'操作员', N'普通操作员');
END
GO

-- Super admin user (password: admin123)
IF NOT EXISTS (SELECT 1 FROM sys_Users WHERE UserName = 'admin')
BEGIN
    INSERT INTO sys_Users (UserName, RealName, PasswordHash, Status, IsSuperAdmin)
    VALUES ('admin', N'超级管理员',
        'F5FA1578EE7F0BFC4A955BFBFB49D22A5B6DE3315862073C3C5B589087B5ECBC',
        1, 1);

    INSERT INTO sys_UserRole (UserID, RoleID)
    VALUES (@@IDENTITY, 1);
END
GO

PRINT 'Database initialization completed successfully.';
GO
