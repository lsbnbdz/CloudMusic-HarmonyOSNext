import { DateUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { pauseMusic, stopMusic } from "../../common/functions/play/playControl"

@Component
export struct TimerSheet {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageLink(StorageConstants.PLAY_COUNTDOWN) countdown: number = 30 * 60 * 1000
  @StorageLink(StorageConstants.PLAY_COUNTDOWN_TIMER) timer: number = -1
  @StorageLink(StorageConstants.PLAY_COUNTDOWN_WORKING) isWorking: boolean = false
  @State selectedTime: number = 30 * 60 * 1000

  build() {
    Column({ space: 15 }) {
      Text('定时关闭')
        .fontColor($r('app.color.reverse'))
        .fontSize(14)

      this.Timer()

      if (!this.isWorking) {
        Button('启动')
          .ButtonStyle()
          .fontWeight(FontWeight.Bolder)
          .onClick(() => {
            this.startTimer()
          })

        Swiper() {
          this.TimePicker()
          this.TimeChooseButton()
        }
        .indicator(
          new DotIndicator()
            .bottom(0)
            .selectedColor($r('app.color.reverse'))
            .color(Color.Gray)
        )
        .clip(false)
        .loop(false)
      } else {
        Button('暂停')
          .ButtonStyle()
          .fontWeight(FontWeight.Bolder)
          .onClick(() => {
            this.pauseTimer()
          })

        Text('已开启定时关闭，将在倒计时结束后自动停止播放')
          .fontSize(12)
          .fontColor(Color.Gray)
          .padding({ top: 15, bottom: 15 })
      }
    }
    .width('100%')
    .padding({
      left: 20, right: 20,
      top: 20, bottom: px2vp(this.bottomRectHeight)
    })
  }

  @Builder Timer() {
    TextTimer({
      isCountDown: true,
      count: this.countdown
    })
      .fontSize(40)
      .fontColor(Color.Gray)
      .fontWeight(FontWeight.Bolder)
      .format('HH:mm:ss')
  }

  @Builder TimePicker() {
    Column({ space: 15 }) {
      TimePicker({
        format: TimePickerFormat.HOUR_MINUTE,
        selected: DateUtil.getFormatDate('2025-01-01 00:30:00')
      })
        .onChange((time) => {
          this.selectedTime = time.hour * 60 * 60 * 1000 + time.minute * 60 * 1000
        })
      Button('设置时间')
        .ButtonStyle()
        .onClick(() => {
          this.countdown = this.selectedTime
        })
    }
    .padding({ bottom: px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI })
    .height(240)
  }

  @Builder TimeChooseButton() {
    Grid() {
      GridItem() { this.chooseTimeButton(false, 15) }.padding({ bottom: 15 })
      GridItem() { this.chooseTimeButton(false, 45) }.padding({ bottom: 15 })
      GridItem() { this.chooseTimeButton(true, 1) }.padding({ bottom: 15 })
      GridItem() { this.chooseTimeButton(true, 2) }.padding({ bottom: 15 })
      GridItem() { this.chooseTimeButton(true, 3) }.padding({ bottom: 15 })
      GridItem() { this.chooseTimeButton(true, 4) }.padding({ bottom: 15 })
    }
    .columnsTemplate('1fr 1fr 1fr')
    .height(240)
    .width('80%')
    .padding({ left: 20, right: 20 })
  }

  /**
   *
   * @param hour boolean
   * @param min number
   */
  @Builder chooseTimeButton(hour: boolean, time: number) {
    Button() {
      Column() {
        Text(time.toString()).fontColor($r('app.color.reverse')).fontWeight(FontWeight.Bolder).fontSize(Constants.FONT_SIZE_COMMON)
        Text(hour ? '小时' : '分钟').fontColor($r('app.color.reverse')).fontSize(10)
      }
    }
    .aspectRatio(1)
    .width(60)
    .buttonStyle(ButtonStyleMode.NORMAL)
    .borderRadius(50)
    .padding(3)
    .onClick(() => {
      this.countdown = hour ? time * 60 * 60 * 1000 : time * 60 * 1000
      this.startTimer()
    })
  }

  /**
   * 启动计时器
   */
  startTimer() {
    this.isWorking = true
    this.timer = setInterval(() => {
      if (this.countdown <= 1000) {
        this.countFinish()
      } else {
        this.countdown -= 1000
      }
    }, 1000)
  }

  /**
   * 暂停计时器
   */
  pauseTimer() {
    this.isWorking = false
    clearInterval(this.timer)
  }

  /**
   * 倒计时归零后操作
   */
  countFinish() {
    clearInterval(this.timer)
    this.countdown = 30 * 60 * 1000
    try {
      pauseMusic()
    }
    catch (e) {
      stopMusic()
    }
    this.isWorking = false
  }
}

@Extend(Button) function ButtonStyle() {
  .buttonStyle(ButtonStyleMode.NORMAL)
  .borderRadius(20)
  .padding({
    left:5,
    right:5
  })
  .width(100)
}