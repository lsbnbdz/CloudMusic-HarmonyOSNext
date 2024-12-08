import { changeCycleMode } from "../../common/functions/playerControl"

@Component
export struct CycleModeButton {

  @StorageLink('cycleMode') cycleMode:number = 0

  build() {
    // 0-顺序播放, 1-顺序循环, 2-单曲循环, 3-随机播放
    if(this.cycleMode == 0) {
      Button() { Image($r('app.media.ic_public_order_play')).image() }
      .button()
      .onClick(() => { changeCycleMode(1) })
    } else if(this.cycleMode == 1) {
      Button() { Image($r('app.media.ic_public_list_cycle')).image() }
      .button()
      .onClick(() => { changeCycleMode(2) })
    } else if(this.cycleMode == 2) {
      Button() { Image($r('app.media.ic_public_single_cycle')).image() }
      .button()
      .onClick(() => { changeCycleMode(3) })
    } else {
      Button() { Image($r('app.media.ic_public_random')).image(25) }
      .button()
      .onClick(() => { changeCycleMode(0) })
    }
  }
}

@Extend(Button) function button() {
  .backgroundColor(Color.Transparent)
  .width(30)
}

@Extend(Image) function image(width: number = 30) {
  .width(width)
  .fillColor($r('app.color.reverse'))
}