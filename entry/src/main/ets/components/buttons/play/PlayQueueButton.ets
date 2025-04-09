import { PlayQueue } from "../../../common/entities/local/PlayQueue"
import BreakpointUtils from "../../../common/utils/system/BreakpointUtils"
import { PlayQueueSheet } from "../../sheets/PlayQueueSheet"

@Component
export struct PlayQueueButton {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isShow: boolean = false
  @State imgWidth: number = 30
  @State imgColor: Color | ResourceStr = $r('app.color.reverse')

  private sheetOptions: SheetOptions = {
    preferType: SheetType.BOTTOM,
    height: BreakpointUtils.getHeightBreakpoint() === 'sm' ? SheetSize.LARGE : '70%',
    dragBar: false,
    showClose: false,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.isShow = false }
  }

  build() {
    Button(){
      Image($r('app.media.ic_public_view_list_filled'))
        .width(this.imgWidth)
        .fillColor(this.imgColor)
        .draggable(false)
    }
    .stateEffect(false)
    .backgroundColor(Color.Transparent)
    .onClick(() => { this.isShow = !this.isShow })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .bindSheet(this.isShow, this.QueueComponent(), this.sheetOptions)
  }

  @Builder
  QueueComponent() {
    PlayQueueSheet({ isShow: this.isShow })
  }
}