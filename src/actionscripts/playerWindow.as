import flash.display.NativeWindowDisplayState
import flash.events.NativeWindowDisplayStateEvent

import mx.events.AIREvent
import mx.events.ListEvent

import radiko.Radiko

private function initWin(event:AIREvent):void {
  var window:PlayerWindow = (event.target as PlayerWindow)
  var station:String = Radiko.DEFAULT_STATION

  // 保存した放送局を読み込む
  try {
    Radiko.openFile(Radiko.STATION_STORAGE, FileMode.READ, function (fs:FileStream):void {
      station = fs.readUTF()
    })
  } catch (error:Error) {
    // stationはRadiko.DEFAULT_STATIONのまま
  }

  // 読み込んだ放送局を選択状態にする
  for each (var value:Object in window.stations.dataProvider) {
    if (value.data == station) {
      window.stations.selectedItem = value
      break
    }
  }

  // 読み込んだ放送局のページを開く
  window.player.location = Radiko.PLAYER_URL_BASE + window.stations.selectedItem.data

  window.stations.addEventListener(ListEvent.CHANGE, function (event:ListEvent):void {
    // 選択された放送局のページを開く
    window.player.location = Radiko.PLAYER_URL_BASE + window.stations.selectedItem.data
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
      window.minimize()
    }
  })
  window.addEventListener(Event.CLOSE, function (event:Event):void {
    // 選択状態の放送局を保存する
    try {
      Radiko.openFile(Radiko.STATION_STORAGE, FileMode.WRITE, function (fs:FileStream):void {
        fs.writeUTF(window.stations.selectedItem.data)
      })
    } catch (error:Error) {
      // 前回保存した放送局のまま
    }
  })

  Radiko.iconMenu.getItemByName(Radiko.MENU_SHOW_WINDOW).checked = true
}