import com.adobe.serialization.json.JSON

import flash.desktop.NativeApplication
import flash.display.NativeWindowDisplayState
import flash.events.NativeWindowDisplayStateEvent

import mx.events.AIREvent
import mx.events.ListEvent

import radiko.Radiko

private function initWin(event:AIREvent):void {
  var window:PlayerWindow = (event.target as PlayerWindow)
  // メモリ使用量軽減対策(効果未確認)
  window.removeEventListener(AIREvent.WINDOW_COMPLETE, initWin)

  var station:String = Radiko.DEFAULT_STATION
  var winMode:int = Radiko.WINDOW_MODE_FULL

  // 設定を読み込む
  try {
    Radiko.openFile(Radiko.CONFIG_FILE, FileMode.READ, function (fs:FileStream):void {
      Radiko.config = JSON.decode(fs.readUTF())
      if (Radiko.config.station != null) station = Radiko.config.station
      if (Radiko.config.winMode != null) winMode = Radiko.config.winMode
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

  // 読み込んだウィンドウモードを選択状態にする
  for each (var wmVal:Object in window.windowMode.dataProvider) {
    if (wmVal.data == winMode) {
      window.windowMode.selectedItem = wmVal
      break
    }
  }

  // 読み込んだ放送局のページを開く
  window.player.location = Radiko.PLAYER_URL_BASE + window.stations.selectedItem.data

  window.stations.addEventListener(ListEvent.CHANGE, function (event:ListEvent):void {
    // 選択された放送局のページを開く
    window.player.location = Radiko.PLAYER_URL_BASE + window.stations.selectedItem.data
  })

  window.windowMode.addEventListener(ListEvent.CHANGE, function (event:ListEvent):void {
    // ウィンドウモードを切り替える
    Radiko.changePlayerWindowMode(window.windowMode.selectedItem.data)
  })

  window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, function (event:NativeWindowDisplayStateEvent):void {
    if (event.afterDisplayState == NativeWindowDisplayState.NORMAL) {
      // ウィンドウを元に戻したら表示してアプリケーションをアクティブにする
      Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked = true
      window.visible = true
      NativeApplication.nativeApplication.activate()
    }
  })
  window.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, function (event:NativeWindowDisplayStateEvent):void {
    if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
      // ウィンドウを最小化したら非表示にする
      Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked = false
      window.visible = false
    }
  })
  window.addEventListener(Event.CLOSING, function (event:Event):void {
    // アプリケーション終了中でなければウィンドウを閉じずに非表示にする
    if (!Radiko.exiting) {
      event.preventDefault()
      window.visible = false  // すぐに消す
      window.minimize()
    }
  })
  window.addEventListener(Event.CLOSE, function (event:Event):void {
    // 設定を保存する
    try {
      Radiko.openFile(Radiko.CONFIG_FILE, FileMode.WRITE, function (fs:FileStream):void {
        Radiko.config.station = window.stations.selectedItem.data
        Radiko.config.winMode = window.windowMode.selectedItem.data
        fs.writeUTF(JSON.encode(Radiko.config))
      })
    } catch (error:Error) {
      trace(error)
    }
  })

  // ウィンドウのタイトル
  var appInfo:Object = Radiko.appInfo
  Radiko.playerWindow.title = appInfo.name + ' Ver. ' + appInfo.version

  Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked = true
  Radiko.changePlayerWindowMode(window.windowMode.selectedItem.data)
}