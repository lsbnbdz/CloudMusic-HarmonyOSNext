import { router } from "@kit.ArkUI"

@Component
export struct RecommendCards {
  build() {
    Row() {
      /**
       * 每日推荐卡片
       */
      Button() {
        Column() {
          Text('每日推荐')
            .width('100%')
            .textStyle(20, true)
          Text('符合你口味的新鲜好歌')
            .width('100%')
            .textStyle(14)
            .textAlign(TextAlign.End)
        }
        .justifyContent(FlexAlign.SpaceAround)
        .height('100%')
        .width('100%')
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      }
      .backgroundImage($r('app.media.RecBg'))
      .backgroundImageSize(ImageSize.Cover)
      .buttonSty()
      .onClick(() => {
        router.pushUrl({
          url: 'pages/DailyListPage'
        })
      })
    }
    .padding({ left: 20, right: 20 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}

@Extend(Button) function buttonSty() {
  .type(ButtonType.Normal)
  .height(80)
  .width('100%')
  .borderRadius(15)
  .backgroundColor(Color.Transparent)
}

@Extend(Text) function textStyle(size: number, isBold: boolean = false) {
  .fontSize(size)
  .fontColor(Color.White)
  .fontWeight(isBold ? FontWeight.Bold : FontWeight.Normal)
}