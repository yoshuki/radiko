package radiko {
  import air.update.ApplicationUpdaterUI

  import flash.desktop.NativeApplication
  import flash.display.NativeMenu
  import flash.display.NativeMenuItem
  import flash.filesystem.File
  import flash.filesystem.FileStream

  public class Radiko {
    public static const PLAYER_URL_BASE:String = 'http://radiko.jp/player/player.html#'
    public static const DEFAULT_STATION:String = 'TBS'
    public static const CONFIG_FILE:String = 'config.json'
    public static const MENU_SHOW_WINDOW:String = 'showWindow'
    public static const WINDOW_MODE_FULL:int = 0
    public static const WINDOW_MODE_MINI:int = 1
    public static const WINDOW_HEIGHT_FULL:int = 725
    public static const WINDOW_HEIGHT_MINI:int = 187
    public static const PLAYER_HEIGHT_FULL:int = 680
    public static const PLAYER_HEIGHT_MINI:int = 142

    // アプリケーション終了中フラグ
    public static var exiting:Boolean = false

    // アプリケーション設定
    private static var _config:Object = {}
    public static function get config():Object {
      return _config
    }
    public static function set config(conf:Object):void {
      _config = conf
    }

    // アプリケーション情報
    public static function get appInfo():Object {
      var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor
      var ns:Namespace = appXML.namespace()
      return {"name": appXML.ns::name, "version": appXML.ns::version}
    }

    // タスクトレイ・ドックアイコンのメニュー
    private static var _iconMenu:NativeMenu = new NativeMenu()
    public static function get iconMenu():NativeMenu {
      return _iconMenu
    }

    // プレイヤーウィンドウ
    private static var _playerWindow:PlayerWindow
    public static function get playerWindow():PlayerWindow {
      return _playerWindow
    }
    public static function set playerWindow(window:PlayerWindow):void {
      _playerWindow = window
    }

    // アップデーター
    private static var _appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI()
    public static function get appUpdater():ApplicationUpdaterUI {
      return _appUpdater
    }

    // ファイルを開く(同期処理)
    public static function openFile(fileName:String, mode:String, handler:Function):void {
      var file:File = File.applicationStorageDirectory.resolvePath(fileName)
      var fs:FileStream = new FileStream()
      fs.open(file, mode)
      handler(fs)
      fs.close()
    }

    // ウィンドウ表示を切り替える
    public static function togglePlayerWindow():void {
      var item:NativeMenuItem = iconMenu.getItemByName(MENU_SHOW_WINDOW)

      // プレイヤーウィンドウを開いたり閉じたり
      if (item.checked) {
        playerWindow.minimize()
      } else {
        if (playerWindow == null || playerWindow.closed) {
          playerWindow = new PlayerWindow()
          playerWindow.open()
        }
        playerWindow.restore()
      }
    }

    // ウィンドウモードを切り替える
    public static function changePlayerWindowMode(mode:int):void {
      var contents:Object = playerWindow.player.domWindow.document.getElementById('contents')

      switch (mode) {
      case WINDOW_MODE_MINI:
        playerWindow.height = WINDOW_HEIGHT_MINI
        playerWindow.player.height = PLAYER_HEIGHT_MINI
        if (contents != null) contents.style.display = 'none'
        break
      default:
        if (contents != null) contents.style.display = ''
        playerWindow.player.height = PLAYER_HEIGHT_FULL
        playerWindow.height = WINDOW_HEIGHT_FULL
        break
      }
    }
 }
}