package radiko {
  import flash.display.NativeMenu
  import flash.filesystem.File
  import flash.filesystem.FileStream

  public class Radiko {
    public static const APP_NAME:String = 'radiko'
    public static const PLAYER_URL_BASE:String = 'http://radiko.jp/player/player.html#'
    public static const DEFAULT_STATION:String = 'TBS'
    public static const STATION_STORAGE:String = 'station.txt'
    public static const MENU_SHOW_WINDOW:String = 'showWindow'

    // アプリケーション終了中フラグ
    public static var exiting:Boolean = false

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