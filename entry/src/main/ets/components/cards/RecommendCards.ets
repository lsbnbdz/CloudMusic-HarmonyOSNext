import { router } from "@kit.ArkUI"
import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { PlayList, playListClass } from "../../common/entities/PlayList"

@Component
export struct RecommendCards {
  @State LikeList:PlayList = playListClass

  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        this.ContentButton(`每日推荐`,'符合你口味的\n新鲜好歌',$r('app.media.bg3'),() => {
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
        this.ContentButton(`我的音乐云盘`,`随时随地畅听`,$r('app.media.bg1'),() => {
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
          .textStyle(Constants.FONT_SIZE_TITLE, true)
        Text(`${secText}`)
          .width('100%')
          .textStyle(Constants.FONT_SIZE_COMMON)
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
  .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
}

@Extend(Text) function textStyle(size: number, isBold: boolean = false) {
  .fontSize(size)
  .fontColor(Color.White)
  .fontWeight(isBold ? FontWeight.Bold : FontWeight.Normal)
}

@Component
export struct RecommendCards_NotLogged {
  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        this.ContentButton(`每日推荐`,'符合你口味的\n新鲜好歌',$r('app.media.bg3'),() => {
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
        this.ContentButton(`我喜欢的歌曲`,`尚未登录`,$r('app.media.bg2'),() => {
          ToastUtil.showToast('请登录后再试')
        })
      }
      .width(150)
      /**
       * 音乐云盘卡片
       */
      ListItem() {
        this.ContentButton(`我的音乐云盘`,`尚未登录`,$r('app.media.bg1'),() => {
          ToastUtil.showToast('请登录后再试')
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
          .textStyle(Constants.FONT_SIZE_TITLE, true)
        Text(`${secText}`)
          .width('100%')
          .textStyle(Constants.FONT_SIZE_COMMON)
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

/**
 * RecommendCards
 * Loading
 * Skeleton
 */
@Component
export struct RecommendCards_Skeleton {
  @State isVisible: boolean = false

  aboutToAppear(): void {
    this.isVisible = true
  }

  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      ListItem() {
        this.ContentButton()
      }
      .width(150)
      ListItem() {
        this.ContentButton()
      }
      .width(150)
      ListItem() {
        this.ContentButton()
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
  ContentButton() {
    Button() {
      Column() {
        Column() {}
        .width('100%')
        .height(Constants.FONT_SIZE_TITLE)
        .backgroundColor($r('app.color.background'))
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

        Column() {}
        .width('80%')
        .height(Constants.FONT_SIZE_COMMON)
        .backgroundColor($r('app.color.background'))
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('100%')
      .padding({ left: 10, right: 10, top: 15, bottom: 15 })
    }
    .opacity(this.isVisible ? 1 : 0)
    .backgroundColor($r('app.color.main'))
    .buttonSty()
    .animation({
      duration: 1500,
      curve: Curve.EaseInOut
    })
  }
}