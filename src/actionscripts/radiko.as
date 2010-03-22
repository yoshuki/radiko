import flash.desktop.NativeApplication
import flash.events.Event

import mx.events.FlexEvent

import radiko.Radiko

[Embed(source='images/radiko16.png')]
private var IconImage16:Class
[Embed(source='images/radiko128.png')]
private var IconImage128:Class

private function initApp(event:FlexEvent):void {
  // メモリ使用量軽減対策(効果未確認)
  (event.target as Application).removeEventListener(FlexEvent.APPLICATION_COMPLETE, initApp)

  if (NativeApplication.supportsSystemTrayIcon || NativeApplication.supportsDockIcon) {
    var menu:NativeMenu = Radiko.iconMenu

    // システムトレイ・ドックアイコンを登録
    var icon:InteractiveIcon
    if (NativeApplication.supportsSystemTrayIcon) {
      var stIcon:SystemTrayIcon = SystemTrayIcon(NativeApplication.nativeApplication.icon)
      icon = stIcon
      stIcon.menu = menu
      var appInfo:Object = Radiko.appInfo
      stIcon.tooltip = appInfo.name + ' ' + appInfo.version
      icon.addEventListener(MouseEvent.CLICK, function (event:MouseEvent):void {
        if (Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked) {
          NativeApplication.nativeApplication.activate()
        } else {
          Radiko.togglePlayerWindow()
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
      Radiko.togglePlayerWindow()
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
        Radiko.togglePlayerWindow()
      }
    })

    // 終了時に、他のイベントで終了中を検知するためフラグを立てる
    NativeApplication.nativeApplication.addEventListener(Event.EXITING, function (event:Event):void {
      Radiko.exiting = true
    })

    // アップデート確認
    Radiko.checkUpdate()
  } else {
    trace('Failed to create icon.')
    // 操作不能回避のため、アイコンが登録できなければ終了
    NativeApplication.nativeApplication.exit()
  }
}