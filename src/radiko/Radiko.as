package radiko {
  import air.update.ApplicationUpdaterUI

  import flash.desktop.NativeApplication
  import flash.display.NativeMenu
  import flash.filesystem.File
  import flash.filesystem.FileStream

  public class Radiko {
    public static const PLAYER_URL_BASE:String = 'http://radiko.jp/player/player.html#'
    public static const DEFAULT_STATION:String = 'TBS'
    public static const STATION_STORAGE:String = 'station.txt'
    public static const MENU_SHOW_WINDOW:String = 'showWindow'

    // アプリケーション終了中フラグ
    public static var exiting:Boolean = false

    // アプリケーション情報
    public static function get appInfo():Object {
      var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor
      var ns:Namespace = appXML.namespace()
      return {'name': appXML.ns::name, 'version': appXML.ns::version}
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
 }
}