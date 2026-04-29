# FGSystemDEV

**Delphi 10 Seattle** 企业级框架项目，基于 JSON/TCP 协议的 C/S 架构。

## 项目结构

```
framework/
├── app_client.dpr          # 客户端主程序
├── app_server.dpr          # 服务端主程序
├── common/                 # 公共定义、类型、工具、资源
├── comm/                   # TCP 通信 & JSON 协议
├── config/                 # 配置管理（加载器、管理器）
├── permission/             # 权限管理（用户、角色、权限）
├── language/               # 多语言管理
├── excel/                  # Excel 导入导出
├── base/                   # 基类（窗体、DataModule）
├── data/                   # 客户端数据集
├── client/                 # 客户端界面
│   ├── uloginfrm.*         # 登录窗口
│   ├── umainfrm.*          # 主窗口
│   ├── ufrmservermonitor.* # 服务器监控
│   ├── modules/            # 功能模块（用户/角色/权限/配置管理）
│   └── template/           # 模板窗体（单表/多表/报表）
├── server/                 # 服务端（主窗口、初始化、容器、方法）
├── lang/                   # 多语言文件（zh-cn, zh-tw, en-us, vi-vn）
└── init_database.sql       # 数据库初始化脚本
```

## 技术栈

- **IDE**: Embarcadero Delphi 10 Seattle (23.0)
- **架构**: Client/Server via TCP + JSON Protocol
- **UI**: VCL (Visual Component Library)
- **数据**: ClientDataSet
- **构建**: MSBuild (.dproj) 或 dcc32 命令行

## 构建

```batch
# 客户端
msbuild app_client.dproj /t:Build /p:Config=Release

# 服务端
msbuild app_server.dproj /t:Build /p:Config=Release

# 或用命令行编译器
dcc32.exe -B app_client.dpr
dcc32.exe -B app_server.dpr
```
