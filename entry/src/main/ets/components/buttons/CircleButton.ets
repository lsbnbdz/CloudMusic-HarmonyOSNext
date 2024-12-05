/**
 * 圆形按钮组件
 */
import FileUtils from "../../common/utils/FileUtils"
import { DialogUtil } from "@pura/harmony-utils"
import { DialogAction } from "@pura/harmony-utils/src/main/ets/entity/constraint"

/**
 * 圆形图标按钮
 */
@Component
export struct CommonCircleButton {
  ButtonImageName: string = ''
  BgColor: string = 'transparent'

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image($r(`app.media.${this.ButtonImageName}`))
          .width(30)
          .fillColor($r('app.color.reverse'))
      }
      .height(35)
      .width(35)
      .backgroundColor(this.BgColor)
      .opacity(0.8)
    }
  }
}

/**
 * 圆形图片按钮
 */
@Component
export struct CircleImageButton {
  imgUrl: string = ''
  BgColor: string = 'transparent'

  build() {
    Column() {
      Button({type: ButtonType.Circle}) {
        Image(this.imgUrl)
          .borderRadius(50)
          .width(35)
          .fillColor($r('app.color.reverse'))
      }
      .height(35)
      .width(35)
      .backgroundColor(this.BgColor)
      .opacity(0.8)
    }
  }
}

/**
 * 圆形“保存”按钮
 */
@Component
export struct SaveCircleButton {
  @Link list:string[]
  @State fileName:string = ''

  build() {
    Button() {
      Image($r('app.media.ic_public_download_filled'))
        .height(40)
        .padding({ top:10, bottom:10, left:10, right:10 })
        .fillColor(Color.White)
    }
    .type(ButtonType.Circle)
    .backgroundColor(Color.Orange)
    .height(60)
    .onClick(() => {
      FileUtils.saveFile(this.fileName)
    })
  }
}

/**
 * 圆形“删除”按钮
 */
@Component
export struct DeleteCircleButton {
  @Link list:string[]
  @State fileName:string = ''
  build() {
    Button() {
      Image($r('app.media.ic_public_delete_filled'))
        .height(40)
        .padding({ top:10, bottom:10, left:10, right:10 })
        .fillColor(Color.White)
    }
    .type(ButtonType.Circle)
    .backgroundColor(Color.Red)
    .height(60)
    .onClick(async () => {
      DialogUtil.showPrimaryDialog({
        title: '删除文件',
        message:`确定删除 "${this.fileName}" ?`,
        primaryButton: "取消",
        secondaryButton: "删除",
        onAction: async (action) => {
          if(action == DialogAction.TWO) {
            await FileUtils.deleteFile(this.fileName).then(async () => {
              this.list = await FileUtils.getFileName()
            })
          }
        }
      })
    })
  }
}