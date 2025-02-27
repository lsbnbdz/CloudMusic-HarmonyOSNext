import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { setHeartMode } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { PlayList } from "../../common/entities/PlayList"
import { playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"

let cardWidth: number = 150

@Builder function ContentButton() {
  Button() {
    Column() {
      Column() {}
      .borderRadius(Constants.RADIUS_IMG)
      .width('80%')
      .height(Constants.FONT_SIZE_TITLE)
      .backgroundColor($r('app.color.background'))
      .alignSelf(ItemAlign.Start)
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

      Column() {}
      .borderRadius(Constants.RADIUS_IMG)
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
  .backgroundColor($r('app.color.main'))
  .buttonSty()
}

@Component
export struct RecommendCards {
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp('UserPlayLists') playLists: Array<PlayList> = []
  @Prop isLogged: boolean

  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        this.ContentButton(`每日推荐`,'符合你口味的\n新鲜好歌',$r('app.media.bg1'),() => {
          if(this.pageInfos.size() == 0) {
            this.pageInfos.pushPathByName('DailyListPage', null)
          } else {
            this.pageInfos.replacePathByName('DailyListPage', null)
          }
        })
      }
      .width(cardWidth)

      /**
       * 音乐云盘卡片
       */
      ListItem() {
        this.ContentButton(`我的音乐云盘`,`随时随地畅听`,$r('app.media.bg2'),() => {
          if(this.isLogged) {
            if(this.pageInfos.size() == 0) {
              this.pageInfos.pushPathByName('CloudPage', null)
            } else {
              this.pageInfos.replacePathByName('CloudPage', null)
            }
          } else {
            ToastUtil.showToast('请登录后再试')
          }
        })
      }
      .width(cardWidth)

      /**
       * 心动歌单卡片
       */
      ListItem() {
        this.ContentButton(`心动歌单`,`智能播放`,$r('app.media.bg3'), async () => {
          if(this.isLogged) {
            DialogUtil.showPrimaryDialog({
              title: '心动歌单',
              message: '是否将播放列表替换为【心动歌单】?\n\n开启心动歌单后，\n将会替换当前播放列表并开始新的播放',
              primaryButton: "取消",
              secondaryButton: {
                value: '确认',
                fontColor: Color.Red,
                action: async () => {
                  try {
                    await setHeartMode(PlayQueueUtils.getCurrentSong().id, this.playLists[0].id)
                    playQueue(0)
                  } catch (e) {
                    ToastUtil.showToast('获取心动模式歌单失败')
                  }
                }
              }
            })
          } else {
            ToastUtil.showToast('请登录后再试')
          }
        })
      }
      .width(cardWidth)

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }

  @Builder
  ContentButton(firText:string, secText:string, imgUrl:ResourceStr, onClick?: () => void ) {
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
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  }
}

@Extend(Button) function buttonSty() {
  .type(ButtonType.Normal)
  .aspectRatio(1)
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

/**
 * RecommendCards
 * Loading
 * Skeleton
 */
@Component
export struct RecommendCards_Skeleton {

  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      ListItem() {
        ContentButton()
      }
      .width(cardWidth)
      ListItem() {
        ContentButton()
      }
      .width(cardWidth)
      ListItem() {
        ContentButton()
      }
      .width(cardWidth)

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }
}