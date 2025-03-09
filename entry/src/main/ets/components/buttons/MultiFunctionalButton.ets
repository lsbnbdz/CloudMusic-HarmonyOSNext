import { VibrateOptions, Vibrator } from "@kit.SensorServiceKit"
import { ObservableScroller } from "../../common/utils/ObservableScroller"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic, playQueue } from "../../common/functions/play/playControl"
import { promptAction } from "@kit.ArkUI"
import playQueueUtils from "../../common/utils/play/PlayQueueUtils"

const maxNum: number = 2
const slideHorizontalThreshold: number = 20
const slideVerticalThreshold: number = 50

@Component
export struct SlideButton {

  @Link index: number
  @State private _slideDirection: string = 'none'
  @State _startX: number = 0
  @State _startY: number = 0
  @State btnScale: number = 1
  @State overlayImage: Resource = $r('app.media.hand_point_up_tap_fill')

  @StorageProp('player-ispaused') isPaused: boolean = true
  @StorageLink('player-isplaying') isPlaying: boolean = false

  build() {
    Button({ type: ButtonType.Circle, stateEffect: true }){
      Column() {
        Image(this.overlayImage)
          .width(35)
          .height(35)
          .opacity(0.8)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .scale({ x: this.btnScale, y: this.btnScale})
    .gesture(
      GestureGroup(GestureMode.Parallel,
        TapGesture({ count: 2 })
          .onAction(() => {
            if (!this.isPaused) {
              this.showToast('暂停')
            } else {
              this.showToast('播放')
            }
            if(!this.isPaused){
              pauseMusic()
            } else {
              if(!this.isPlaying){
                playQueue(playQueueUtils.currentQueueIndex)
              } else {
                resumeMusic()

              }
            }
          })
      )
    )
    .onTouch((event: TouchEvent) => {
      switch (event.type) {
        case TouchType.Down:
          this.handleTouchDown(event)
          break
        case TouchType.Move:
          this.handleTouchMove(event)
          break
        case TouchType.Up:
          this.handleTouchUp()
          break
      }
    })
    .width(45)
    .height(45)
    .margin({ bottom: 90, right: -250 })
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .opacity(0.8)
    .backgroundColor($r('app.color.btn_background'))
  }

  triggerVibration() {
    try {
      let vibrateOptions: VibrateOptions = {
        mode: 'short',
        success: () => {
          // console.info('Succeed in vibrating');
        },
        fail: (data: string, code: number) => {
          console.info(`Failed to vibrate. Data: ${data}, code: ${code}`);
        },
        complete: () => {
          console.info('completed in vibrating');
        }
      };

      Vibrator.vibrate(vibrateOptions)
    } catch (error) {
      console.error('震动功能不可用')
    }
  }

  // 触摸按下处理
  handleTouchDown(event: TouchEvent) {
    this._startX = event.touches[0].x
    this._startY = event.touches[0].y
    this.btnScale = 0.90
    this._slideDirection = 'none'
  }

  // 触摸移动处理
  handleTouchMove(event: TouchEvent) {
    const currentX = event.touches[0].x
    const currentY = event.touches[0].y
    const deltaX = currentX - this._startX
    const deltaY = currentY - this._startY

    // 实时更新滑动方向反馈
    if (Math.abs(deltaY) > slideVerticalThreshold) {
      this._slideDirection = deltaY > 0 ? 'up' : 'down'
      return
    }
    if (Math.abs(deltaX) > slideHorizontalThreshold) {
      this._slideDirection = deltaX > 0 ? 'right' : 'left'
    }
  }

  // 触摸抬起处理
  handleTouchUp() {

    switch (this._slideDirection){
      case 'down':
        playPre()
        this.showToast('上一首')
        break
      case 'up':
        playNext()
        this.showToast('下一首')
        break
      case 'left':
        this.onSlideLeft()
        this.showTitleToast()
        break
      case 'right':
        this.onSlideRight()
        this.showTitleToast()
        break
    }

    this.btnScale = 1
    if(this._slideDirection != 'none'){
      this.triggerVibration()
    }
  }

  showTitleToast() {
    switch (this.index) {
      case 0:
        this.showToast('发现')
        break
      case 1:
        this.showToast('歌单')
        break
      case 2:
        this.showToast('我的')
    }
  }

  showToast(msg: string) {
    promptAction.showToast({ message: msg, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.BACKGROUND_THIN })
  }

  // 左滑回调
  onSlideLeft() {
    console.log('左滑操作触发')
    if(this.index === 0){
      this.index = maxNum
    }else{
      this.index--;
    }
  }

  // 右滑回调
  onSlideRight() {
    console.log('右滑操作触发')
    if(this.index === maxNum){
      this.index = 0
    }else{
      this.index++;
    }
  }

}

@Component
export struct MultiFunctionalButton {
  @State btnScale: number = 1

  @State private _slideDirection: string = 'none'
  @State private _startX: number = 0
  @State private _startY: number = 0
  @Link index: number
  @Link observableScroller: ObservableScroller

  @StorageProp('player-ispaused') isPaused: boolean = true
  @StorageLink('player-isplaying') isPlaying: boolean = false

  build() {

    Button({ type: ButtonType.Circle, stateEffect: true }){
      Column() {
        Image($r('app.media.hand_point_up_tap_fill'))
          .width(35)
          .height(35)
          .opacity(0.8)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .scale({ x: this.btnScale, y: this.btnScale })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 2 })
          .onAction(() => {
            if (!this.isPaused) {
              this.showToast('暂停')
            } else {
              this.showToast('播放')
            }
            if(!this.isPaused){
              pauseMusic()
            } else {
              if(!this.isPlaying){
                playQueue(playQueueUtils.currentQueueIndex)
              } else {
                resumeMusic()
              }
            }
          }),
        TapGesture({ count: 1 })
          .onAction(() => {
            this.observableScroller.scrollToTop()
          })
      )
    )
    .onTouch((event: TouchEvent) => {
      switch (event.type) {
        case TouchType.Down:
          this.handleTouchDown(event)
          break
        case TouchType.Move:
          this.handleTouchMove(event)
          break
        case TouchType.Up:
          this.handleTouchUp()
          break
      }
    })
    .width(45)
    .height(45)
    .margin({ bottom: 90, right: -250 })
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .opacity(0.8)
    .backgroundColor($r('app.color.btn_background'))
    // .onClick(() => this.observableScroller.scrollToTop())

  }

  triggerVibration() {
    try {
      let vibrateOptions: VibrateOptions = {
        mode: 'short',
        success: () => {
          // console.info('Succeed in vibrating');
        },
        fail: (data: string, code: number) => {
          console.info(`Failed to vibrate. Data: ${data}, code: ${code}`);
        },
        complete: () => {
          console.info('completed in vibrating');
        }
      };

      Vibrator.vibrate(vibrateOptions)
    } catch (error) {
      console.error('震动功能不可用')
    }
  }

  // 触摸按下处理
  handleTouchDown(event: TouchEvent) {
    this._startX = event.touches[0].x
    this._startY = event.touches[0].y
    this._slideDirection = 'none'
    this.btnScale = 0.90
  }

  // 触摸移动处理
  handleTouchMove(event: TouchEvent) {
    const currentX = event.touches[0].x
    const currentY = event.touches[0].y
    const deltaX = currentX - this._startX
    const deltaY = currentY - this._startY

    // 实时更新滑动方向反馈
    if (Math.abs(deltaY) > slideVerticalThreshold) {
      this._slideDirection = deltaY > 0 ? 'up' : 'down'
      return
    }
    if (Math.abs(deltaX) > slideHorizontalThreshold) {
      this._slideDirection = deltaX > 0 ? 'right' : 'left'
    }
  }

  // 触摸抬起处理
  handleTouchUp() {

    switch (this._slideDirection){
      case 'down':
        playPre()
        this.showToast('上一首')
        break
      case 'up':
        playNext()
        this.showToast('下一首')
        break
      case 'left':
        this.onSlideLeft()
        this.showTitleToast()
        break
      case 'right':
        this.onSlideRight()
        this.showTitleToast()
        break
    }

    this.btnScale = 1
    if(this._slideDirection != 'none'){
      this.triggerVibration()
    }
  }

  showTitleToast() {
    switch (this.index) {
      case 0:
        this.showToast('发现')
        break
      case 1:
        this.showToast('歌单')
        break
      case 2:
        this.showToast('我的')
    }
  }

  showToast(msg: string) {
    promptAction.showToast({ message: msg, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.BACKGROUND_THIN })
  }

  // 左滑回调
  onSlideLeft() {
    if(this.index === 0){
      this.index = maxNum
    }else{
      this.index--;
    }

  }

  // 右滑回调
  onSlideRight() {
    if(this.index === maxNum){
      this.index = 0
    }else{
      this.index++;
    }
  }

}

@Component
export struct PlayListOverlayButton {
  @State btnScale: number = 1

  @State private _slideDirection: string = 'none'
  @State private _startX: number = 0
  @State private _startY: number = 0
  @Link observableScroller: ObservableScroller

  @StorageProp('player-ispaused') isPaused: boolean = true
  @StorageLink('player-isplaying') isPlaying: boolean = false

  build() {

    Button({ type: ButtonType.Circle, stateEffect: true }){
      Column() {
        Image($r('app.media.hand_point_up_tap_fill'))
          .width(35)
          .height(35)
          .opacity(0.8)
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .scale({ x: this.btnScale, y: this.btnScale })
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        TapGesture({ count: 2 })
          .onAction(() => {
            if (!this.isPaused) {
              this.showToast('暂停')
            } else {
              this.showToast('播放')
            }
            if(!this.isPaused){
              pauseMusic()
            } else {
              if(!this.isPlaying){
                playQueue(playQueueUtils.currentQueueIndex)
              } else {
                resumeMusic()
              }
            }
          }),
        TapGesture({ count: 1 })
          .onAction(() => {
            this.observableScroller.scrollToTop()
          })
      )
    )
    .onTouch((event: TouchEvent) => {
      switch (event.type) {
        case TouchType.Down:
          this.handleTouchDown(event)
          break
        case TouchType.Move:
          this.handleTouchMove(event)
          break
        case TouchType.Up:
          this.handleTouchUp()
          break
      }
    })
    .width(45)
    .height(45)
    .margin({ bottom: 90, right: -250 })
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
    .opacity(0.8)
    .backgroundColor($r('app.color.btn_background'))
    // .onClick(() => this.observableScroller.scrollToTop())

  }

  triggerVibration() {
    try {
      let vibrateOptions: VibrateOptions = {
        mode: 'short',
        success: () => {
          // console.info('Succeed in vibrating');
        },
        fail: (data: string, code: number) => {
          console.info(`Failed to vibrate. Data: ${data}, code: ${code}`);
        },
        complete: () => {
          console.info('completed in vibrating');
        }
      };

      Vibrator.vibrate(vibrateOptions)
    } catch (error) {
      console.error('震动功能不可用')
    }
  }

  // 触摸按下处理
  handleTouchDown(event: TouchEvent) {
    this._startX = event.touches[0].x
    this._startY = event.touches[0].y
    this._slideDirection = 'none'
    this.btnScale = 0.90
  }

  // 触摸移动处理
  handleTouchMove(event: TouchEvent) {
    const currentX = event.touches[0].x
    const currentY = event.touches[0].y
    const deltaX = currentX - this._startX
    const deltaY = currentY - this._startY

    // 实时更新滑动方向反馈
    if (Math.abs(deltaY) > slideVerticalThreshold) {
      this._slideDirection = deltaY > 0 ? 'up' : 'down'
      return
    }
    if (Math.abs(deltaX) > slideHorizontalThreshold) {
      this._slideDirection = deltaX > 0 ? 'right' : 'left'
    }
  }

  // 触摸抬起处理
  handleTouchUp() {

    switch (this._slideDirection){
      case 'down':
        playPre()
        this.triggerVibration()
        this.showToast('上一首')
        break
      case 'up':
        playNext()
        this.triggerVibration()
        this.showToast('下一首')
        break
    }

    this.btnScale = 1
    // if(this._slideDirection != 'none'){
    //   this.triggerVibration()
    // }
  }

  showToast(msg: string) {
    promptAction.showToast({ message: msg, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.BACKGROUND_THIN })
  }

}
