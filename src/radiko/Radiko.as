package radiko {
  import air.update.ApplicationUpdaterUI;

  import flash.desktop.NativeApplication;
  import flash.display.NativeMenu;
  import flash.display.NativeMenuItem;
  import flash.events.ErrorEvent;
  import flash.filesystem.File;
  import flash.filesystem.FileStream;

  import mx.collections.IList;

  public class Radiko {
    public static const PLAYER_URL_BASE:String = 'http://radiko.jp/player/player.html#';
    public static const DEFAULT_REGION:String = REGION_KANTO;
    public static const DEFAULT_STATION:String = 'TBS';
    public static const CONFIG_FILE:String = 'config.json';
    public static const MENU_SHOW_WINDOW:String = 'showWindow';
    public static const WINDOW_TOGGLE_SHOW:int = 0;
    public static const WINDOW_TOGGLE_HIDE:int = 1;
    public static const WINDOW_MODE_FULL:int = 0;
    public static const WINDOW_MODE_MINI:int = 1;
    public static const WINDOW_HEIGHT_FULL:int = 730;
    public static const WINDOW_HEIGHT_MINI:int = 195;
    public static const PLAYER_HEIGHT_FULL:int = 680;
    public static const PLAYER_HEIGHT_MINI:int = 150;
    public static const REGION_KANTO:String = 'KANTO';
    public static const REGION_KANSAI:String = 'KANSAI';
    public static const REGION_CHUKYO:String = 'CHUKYO';
    public static const REGION_HOKKAIDO:String = 'HOKKAIDO';
    public static const REGION_FUKUOKA:String = 'FUKUOKA';

    // アプリケーション終了中フラグ
    public static var exiting:Boolean = false;

    // アプリケーション情報
    public static function get appInfo():Object {
      var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
      var ns:Namespace = appXML.namespace();
      return {"name": appXML.ns::name, "version": appXML.ns::version};
    }

    // タスクトレイ・ドックアイコンのメニュー
    private static var _iconMenu:NativeMenu = new NativeMenu();
    public static function get iconMenu():NativeMenu {
      return _iconMenu;
    }

    // アプリケーション設定
    private static var _config:Object = {}
    public static function get config():Object {
      return _config;
    }
    public static function set config(conf:Object):void {
      _config = conf;
    }

    // プレイヤーウィンドウ
    private static var _playerWindow:PlayerWindow;
    public static function get playerWindow():PlayerWindow {
      return _playerWindow;
    }
    public static function set playerWindow(window:PlayerWindow):void {
      _playerWindow = window;
    }

    // ファイルを開く(同期処理)
    public static function openFile(fileName:String, mode:String, handler:Function):void {
      var file:File = File.applicationStorageDirectory.resolvePath(fileName);
      var fs:FileStream = new FileStream();
      fs.open(file, mode);
      handler(fs);
      fs.close();
    }

    // ウィンドウ表示を切り替える
    public static function togglePlayerWindow(action:int=-1):void {
      var item:NativeMenuItem = iconMenu.getItemByName(MENU_SHOW_WINDOW);

      switch (action) {
      case WINDOW_TOGGLE_SHOW:
        item.checked = true;
        break;
      case WINDOW_TOGGLE_HIDE:
        item.checked = false;
        break;
      default:
        item.checked = !item.checked;
      }

      // プレイヤーウィンドウを表示したり消したり
      if (item.checked) {
        if (playerWindow == null || playerWindow.closed) {
          playerWindow = new PlayerWindow();
          playerWindow.open();
        }
        playerWindow.visible = true;
        playerWindow.restore();
        NativeApplication.nativeApplication.activate();
      } else {
        playerWindow.visible = false;
      }
    }

    // ウィンドウモードを切り替える
    public static function changePlayerWindowMode(mode:int):void {
      var contents:Object = playerWindow.player.domWindow.document.getElementById('contents');

      switch (mode) {
      case WINDOW_MODE_MINI:
        playerWindow.height = WINDOW_HEIGHT_MINI;
        playerWindow.player.height = PLAYER_HEIGHT_MINI;
        if (contents != null) contents.style.display = 'none';
        break;
      default:
        if (contents != null) contents.style.display = '';
        playerWindow.player.height = PLAYER_HEIGHT_FULL;
        playerWindow.height = WINDOW_HEIGHT_FULL;
      }
    }

    // 地域を切り替える
    public static function changeRegion(region:String, station:String=null):void {
      Radiko.config.region = region;

      var stationValues:IList;
      playerWindow.stationValues.removeAll();
      switch (region) {
        case Radiko.REGION_KANSAI:
          stationValues = playerWindow.stationValuesKansai;
          break;
        case Radiko.REGION_CHUKYO:
          stationValues = playerWindow.stationValuesChukyo;
          break;
        case Radiko.REGION_HOKKAIDO:
          stationValues = playerWindow.stationValuesHokkaido;
          break;
        case Radiko.REGION_FUKUOKA:
          stationValues = playerWindow.stationValuesFukuoka;
          break;
        default:
          stationValues = playerWindow.stationValuesKanto;
      }
      playerWindow.stationValues.addAll(stationValues);

      // 指定された放送局を選択状態にする
      var sVals:Array = playerWindow.stations.dataProvider.toArray();
      for each (var sVal:Object in sVals) {
        if (sVal.data == station) {
          playerWindow.stations.selectedItem = sVal;
          break;
        }
      }
      if (playerWindow.stations.selectedItem == null) playerWindow.stations.selectedItem = sVals[0];
      changeStation(playerWindow.stations.selectedItem.data);
    }

    // 放送局を切り替える
    public static function changeStation(station:String):void {
      Radiko.config.station = station;
      playerWindow.player.location = Radiko.PLAYER_URL_BASE + station;
    }

    // アップデート確認
    public static function checkUpdate():void {
      var appUpdater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
      appUpdater.configurationFile = new File("app:/update-config.xml");
      appUpdater.addEventListener(ErrorEvent.ERROR, function (event:ErrorEvent):void {
        // 動作に直接の支障はないため無視
      });
      appUpdater.initialize();
    }
  }
}
