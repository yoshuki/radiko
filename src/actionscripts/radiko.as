import flash.desktop.NativeApplication
import flash.events.ErrorEvent
import flash.events.Event

import mx.events.FlexEvent

import radiko.Radiko

[Embed(source='images/radiko16.png')]
private var IconImage16:Class
[Embed(source='images/radiko128.png')]
private var IconImage128:Class

private function togglePlayerWindow():void {
  var item:NativeMenuItem = Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW)
  var window:PlayerWindow = Radiko.playerWindow

  // プレイヤーウィンドウを開いたり閉じたり
  if (item.checked) {
    window.minimize()
  } else {
    if (window == null || window.closed) {
      Radiko.playerWindow = window = new PlayerWindow()
      window.open()
    }
    window.restore()
  }
}

private function initApp(event:FlexEvent):void {
  if (NativeApplication.supportsSystemTrayIcon || NativeApplication.supportsDockIcon) {
    var menu:NativeMenu = Radiko.iconMenu

    // システムトレイ・ドックアイコンを登録
    var icon:InteractiveIcon
    if (NativeApplication.supportsSystemTrayIcon) {
      var stIcon:SystemTrayIcon = SystemTrayIcon(NativeApplication.nativeApplication.icon)
      icon = stIcon
      stIcon.menu = menu
      stIcon.tooltip = Radiko.appInfo.name
      icon.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
        if (Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked) {
          NativeApplication.nativeApplication.activate()
        } else {
          togglePlayerWindow()
        }
      })
    } else if (NativeApplication.supportsDockIcon) {
      var dIcon:DockIcon = DockIcon(NativeApplication.nativeApplication.icon)
      icon = dIcon
      dIcon.menu = menu
    }

    // アイコン画像
    var iconImage16:Bitmap  = Bitmap(new IconImage16())
    var iconImage128:Bitmap = Bitmap(new IconImage128())
    icon.bitmaps = [iconImage16, iconImage128]

    // メニュー - 表示
    var showWindowItem:NativeMenuItem = new NativeMenuItem('radikoを表示')
    menu.addItem(showWindowItem)
    showWindowItem.name = Radiko.MENU_SHOW_WINDOW
    showWindowItem.addEventListener(Event.SELECT, function (event:Event):void {
      togglePlayerWindow()
    })

    // メニュー - 終了
    var exitItem:NativeMenuItem = new NativeMenuItem('radikoを終了')
    menu.addItem(exitItem)
    exitItem.addEventListener(Event.SELECT, function (event:Event):void {
      NativeApplication.nativeApplication.exit()
    })

    // Windowsは起動時のみ、Macはドックアイコンをクリック時にも起きる
    NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, function (event:InvokeEvent):void {
      if (Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked) {
        NativeApplication.nativeApplication.activate()
      } else {
        togglePlayerWindow()
      }
    })

    // 終了時に、他のイベントで終了中を検知するためフラグを立てる
    NativeApplication.nativeApplication.addEventListener(Event.EXITING, function (event:Event):void {
      Radiko.exiting = true
    })

    // アップデート確認
    Radiko.appUpdater.configurationFile = new File("app:/update-config.xml")
    Radiko.appUpdater.addEventListener(ErrorEvent.ERROR, function (event:ErrorEvent):void {
      // 動作に直接の支障はないため無視
    })
    Radiko.appUpdater.initialize()
  } else {
    trace('Failed to create icon.')
    // 操作不能回避のため、アイコンが登録できなければ終了
    NativeApplication.nativeApplication.exit()
  }
}