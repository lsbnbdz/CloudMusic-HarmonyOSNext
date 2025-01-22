import { TimerSheet } from "../../sheets/TimerSheet"

@Component
export struct TimerButton {
  @Prop isTimerWorking: boolean = false
  @State isShow: boolean = false

  build() {
    Column() {
      Image($r('app.media.ic_clock'))
        .fillColor(this.isTimerWorking ? $r('app.color.blue') : Color.White)
        .width(20)
        .draggable(false)
        .backgroundColor(Color.Transparent)
        .onClick(() => { this.isShow = !this.isShow })
        .bindSheet(this.isShow, this.Timer(), {
          preferType: SheetType.CENTER,
          height: SheetSize.FIT_CONTENT,
          dragBar: false,
          showClose: true,
          backgroundColor: $r('app.color.background'),
          onDisappear: () => { this.isShow = false }
        })
    }
    .width(30)
    .height(30)
  }

  @Builder Timer() {
    TimerSheet()
  }

}