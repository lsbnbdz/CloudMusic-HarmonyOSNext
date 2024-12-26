import { router } from "@kit.ArkUI"
import { playList, playListClass } from "../../common/entities/PlayList"

@Component
export struct RecommendCards {
  @State LikeList:playList = playListClass

  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        this.ContentButton(`每日推荐`,'符合你口味的\n新鲜好歌',$r('app.media.bg1'),() => {
          router.pushUrl({
            url: 'pages/DailyListPage',
          })
        })
      }
      .width(150)
      /**
       * 喜欢的音乐卡片
       */
      ListItem() {
        this.ContentButton(`${this.LikeList.name}`,`${this.LikeList.trackCount} 首歌曲`,$r('app.media.bg2'),() => {
          router.pushUrl({
            url: 'pages/PlayListPage',
            params: { 'playList': this.LikeList, 'trackCount': this.LikeList.trackCount }
          })
        })
      }
      .width(150)
      /**
       * 音乐云盘卡片
       */
      ListItem() {
        this.ContentButton(`我的音乐云盘`,`随时随地畅听`,$r('app.media.bg3'),() => {
          router.pushUrl({
            url: 'pages/CloudPage',
          })
        })
      }
      .width(150)

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }

  @Builder
  ContentButton(firText:string, secText:string, imgUrl:ResourceStr, onClick: ()=>void) {
    Button() {
      Column() {
        Text(`${firText}`)
          .width('100%')
          .textStyle(20, true)
        Text(`${secText}`)
          .width('100%')
          .textStyle(14)
          .textAlign(TextAlign.Center)
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('100%')
      .padding({ left: 10, right: 10, top: 15, bottom: 15 })
    }
    .backgroundImage(imgUrl)
    .backgroundImageSize(ImageSize.Cover)
    .buttonSty()
    .onClick(onClick)
  }
}

@Extend(Button) function buttonSty() {
  .type(ButtonType.Normal)
  .height(150)
  .width('100%')
  .borderRadius(15)
  .backgroundColor(Color.Transparent)
  .backgroundBlurStyle(BlurStyle.Thin)
}

@Extend(Text) function textStyle(size: number, isBold: boolean = false) {
  .fontSize(size)
  .fontColor(Color.White)
  .fontWeight(isBold ? FontWeight.Bold : FontWeight.Normal)
}