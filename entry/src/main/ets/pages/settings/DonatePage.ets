import Constants from "../../common/constants/Constants"

@Component
export struct DonatePage {
  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 30 }) {
          Image($r("app.media.donate"))
            .width('80%')
            .borderRadius(Constants.RADIUS_IMG)
            .constraintSize({
              maxWidth: 350,
              minWidth: 200
            })

          Column({ space: 20 }) {
            Text('特别鸣谢')
              .fontSize(Constants.FONT_SIZE_TITLE)
              .fontWeight(Constants.FONT_WEIGHT_SETTINGS)
              .fontColor($r('app.color.reverse'))

            Text('随应用版本更新~')
              .fontSize(Constants.FONT_SIZE_COMMON)
              .fontColor($r('app.color.reverse'))
          }
        }
        .height('100%')
        .width('100%')
        .padding({ top: Constants.PADDING_EDGE_TEXT })
      }
    }
    .title('捐赠')
    .backgroundColor($r('app.color.background'))
  }
}