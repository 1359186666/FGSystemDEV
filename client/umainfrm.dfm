object MainFrm: TMainFrm
  Left = 0
  Top = 0
  Caption = 'Enterprise Management System'
  ClientHeight = 600
  ClientWidth = 1024
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = mmMain
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object tbMain: TToolBar
    Left = 0
    Top = 0
    Width = 1024
    Height = 29
    Caption = 'tbMain'
    Images = ilMain
    TabOrder = 0
    object btnLogout: TToolButton
      Left = 0
      Top = 0
      Action = actLogout
    end
    object btnAdmin: TToolButton
      Left = 23
      Top = 0
      Action = actUserMgr
    end
  end
  object sbMain: TStatusBar
    Left = 0
    Top = 581
    Width = 1024
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object mmMain: TMainMenu
    Left = 120
    Top = 88
    object miFile: TMenuItem
      Caption = '&File'
      object miAdmin: TMenuItem
        Caption = 'System Admin'
        object miUserMgr: TMenuItem
          Action = actUserMgr
        end
        object miRoleMgr: TMenuItem
          Action = actRoleMgr
        end
        object N2: TMenuItem
          Caption = '-'
        end
        object miPermission: TMenuItem
          Action = actPermissionMgr
        end
        object miModuleConfig: TMenuItem
          Action = actModuleConfig
        end
        object miLangMgr: TMenuItem
          Action = actLangMgr
        end
      end
      object miChangePwd: TMenuItem
        Action = actChangePwd
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object miLogout: TMenuItem
        Action = actLogout
      end
      object miExit: TMenuItem
        Action = actExit
      end
    end
    object miWindow: TMenuItem
      Caption = '&Window'
      object miCascade: TMenuItem
        Action = actCascade
      end
      object miTileH: TMenuItem
        Action = actTileH
      end
      object miTileV: TMenuItem
        Action = actTileV
      end
      object miCloseAll: TMenuItem
        Action = actCloseAll
      end
    end
    object miHelp: TMenuItem
      Caption = '&Help'
      object miAbout: TMenuItem
        Action = actAbout
      end
    end
  end
  object ilMain: TImageList
    Left = 200
    Top = 88
  end
  object alMain: TActionList
    Left = 280
    Top = 88
    object actExit: TAction
      Caption = 'Exit'
      OnExecute = actExitExecute
    end
    object actLogout: TAction
      Caption = 'Logout'
      OnExecute = actLogoutExecute
    end
    object actCascade: TAction
      Caption = 'Cascade'
      OnExecute = actCascadeExecute
    end
    object actTileH: TAction
      Caption = 'Horizontal Tile'
      OnExecute = actTileHExecute
    end
    object actTileV: TAction
      Caption = 'Vertical Tile'
      OnExecute = actTileVExecute
    end
    object actCloseAll: TAction
      Caption = 'Close All'
      OnExecute = actCloseAllExecute
    end
    object actAbout: TAction
      Caption = 'About'
      OnExecute = actAboutExecute
    end
    object actUserMgr: TAction
      Caption = 'User Management'
      OnExecute = actUserMgrExecute
    end
    object actRoleMgr: TAction
      Caption = 'Role Management'
      OnExecute = actRoleMgrExecute
    end
    object actPermissionMgr: TAction
      Caption = 'Permission Management'
      OnExecute = actPermissionMgrExecute
    end
    object actModuleConfig: TAction
      Caption = 'Module Configuration'
      OnExecute = actModuleConfigExecute
    end
    object actLangMgr: TAction
      Caption = 'Language Manager'
      OnExecute = actLangMgrExecute
    end
    object actChangePwd: TAction
      Caption = 'Change Password'
      OnExecute = actChangePwdExecute
    end
  end
end
