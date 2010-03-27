import com.adobe.serialization.json.JSON

import flash.display.NativeWindowDisplayState
import flash.display.Screen
import flash.events.Event
import flash.events.NativeWindowDisplayStateEvent
import flash.geom.Rectangle

import mx.controls.HTML
import mx.core.Window
import mx.events.AIREvent
import mx.events.FlexNativeWindowBoundsEvent
import mx.events.ListEvent

import radiko.Radiko

private function initWin(event:AIREvent):void {
  var window:PlayerWindow = (event.target as PlayerWindow)
  // メモリ使用量軽減対策
  window.removeEventListener(AIREvent.WINDOW_COMPLETE, initWin)

  var station:String = Radiko.DEFAULT_STATION
  var winMode:int = Radiko.WINDOW_MODE_FULL
  var winPosX:Number
  var winPosY:Number

  // 設定を読み込む
  try {
    Radiko.openFile(Radiko.CONFIG_FILE, FileMode.READ, function (fs:FileStream):void {
      var config:Object = Radiko.config = JSON.decode(fs.readUTF())
      if (config.station != null) station = config.station
      if (config.winMode != null) winMode = config.winMode
      if (config.winPosX != null) winPosX = config.winPosX
      if (config.winPosY != null) winPosY = config.winPosY
    })
  } catch (error:Error) {
    trace(error)
  }

  // 読み込んだ放送局を選択状態にする
  for each (var sVal:Object in window.stations.dataProvider) {
    if (sVal.data == station) {
      window.stations.selectedItem = sVal
      break
    }
  }

  // 読み込んだ放送局のページを開く
  window.player.location = Radiko.PLAYER_URL_BASE + station

  // 読み込んだウィンドウモードを選択状態にする
  for each (var wmVal:Object in window.windowMode.dataProvider) {
    if (wmVal.data == winMode) {
      window.windowMode.selectedItem = wmVal
      break
    }
  }

  // 読み込んだウィンドウモードに切り替える
  Radiko.changePlayerWindowMode(winMode)

  var vb:Rectangle = Screen.mainScreen.visibleBounds

  // ウィンドウモード変更後のウィンドウサイズで中心を計算する
  if (isNaN(winPosX)) winPosX = vb.right / 2 - window.width / 2
  if (isNaN(winPosY)) winPosY = vb.bottom / 2 - window.height / 2

  // 表示領域外だった場合には補正する
  if (winPosX < vb.left)   winPosX = vb.left
  if (winPosX > vb.right)  winPosX = vb.right - window.width
  if (winPosY < vb.top)    winPosY = vb.top
  if (winPosY > vb.bottom) winPosY = vb.bottom - window.height

  // ウィンドウを移動する
  window.nativeWindow.x = winPosX
  window.nativeWindow.y = winPosY

  // ウィンドウのタイトル
  var appInfo:Object = Radiko.appInfo
  Radiko.playerWindow.title = appInfo.name + ' ' + appInfo.version

  // メニューの表示状態をウィンドウの表示状態に合わせる
  Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked = window.visible

  window.stations.addEventListener(ListEvent.CHANGE, function (event:ListEvent):void {
    var data:String = (event.target as ComboBox).selectedItem.data
    Radiko.config.station = data
    // 選択された放送局のページを開く
    Radiko.playerWindow.player.location = Radiko.PLAYER_URL_BASE + data
  })

  window.windowMode.addEventListener(ListEvent.CHANGE, function (event:ListEvent):void {
    var data:int = (event.target as ComboBox).selectedItem.data
    Radiko.config.winMode = data
    // ウィンドウモードを切り替える
    Radiko.changePlayerWindowMode(data)
  })

  window.addEventListener(FlexNativeWindowBoundsEvent.WINDOW_MOVE, function (event:FlexNativeWindowBoundsEvent):void {
    // ウィンドウの現在地を保存する
    var nw:NativeWindow = (event.target as Window).nativeWindow
    Radiko.config.winPosX = nw.x
    Radiko.config.winPosY = nw.y
  })
  window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, function (event:NativeWindowDisplayStateEvent):void {
    // ウィンドウを最小化時には非表示にし、復元時には表示する
    switch (event.afterDisplayState) {
    case NativeWindowDisplayState.MINIMIZED:
      Radiko.togglePlayerWindow(Radiko.WINDOW_TOGGLE_HIDE)
      break
    case NativeWindowDisplayState.NORMAL:
      Radiko.togglePlayerWindow(Radiko.WINDOW_TOGGLE_SHOW)
      break
    }
  })
  window.addEventListener(Event.CLOSING, function (event:Event):void {
    if (!Radiko.exiting) {
      // アプリケーション終了中でなければウィンドウを閉じずに非表示にする
      event.preventDefault()
      Radiko.togglePlayerWindow(Radiko.WINDOW_TOGGLE_HIDE)
    }
  })
  window.addEventListener(Event.CLOSE, function (event:Event):void {
    // 設定を保存する
    try {
      Radiko.openFile(Radiko.CONFIG_FILE, FileMode.WRITE, function (fs:FileStream):void {
        fs.writeUTF(JSON.encode(Radiko.config))
      })
    } catch (error:Error) {
      trace(error)
    }
  })
}

private function initHtml(event:Event):void {
  var html:HTML = (event.target as HTML)
  // クリックでリンク先を開くためにJSの関数を置き換える
  html.domWindow.openWeb = (function (url:String, target:String='radiko_opener'):void {
      navigateToURL(new URLRequest(url), target)
    })
}