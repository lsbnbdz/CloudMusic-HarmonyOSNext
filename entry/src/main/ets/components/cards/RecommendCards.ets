import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { setHeartMode } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/PlayList"
import { playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"

let cardWidth: number = 120

@Builder function ContentButton(firText:string, secText:string, imgUrl:ResourceStr, onClick?: () => void ) {
  Button() {
    Column() {
      Text(`${firText}`)
        .width('100%')
        .textStyle(Constants.FONT_SIZE_COMMON + 2, true)
        .padding(Constants.PADDING_EDGE_DEFAULT)
        .textShadow({ radius: 15 })
      Text(`${secText}`)
        .width('100%')
        .textStyle(Constants.FONT_SIZE_BAR)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
        .textShadow({ radius: 5 })
        .borderRadius({ bottomLeft: Constants.RADIUS_IMG, bottomRight: Constants.RADIUS_IMG })
        .height(Constants.FONT_SIZE_COMMON * 2)
        .backdropBlur(100)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height('100%')
    .width('100%')
  }
  .backgroundImage(imgUrl)
  .backgroundImageSize(ImageSize.Cover)
  .buttonSty()
  .onClick(onClick)
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
  .width(cardWidth)
  .height(cardWidth + 30)
}

@Component
export struct RecommendCards {
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @Prop isLogged: boolean

  build() {
    List({ space: 15 }) {
      ListItem().width(5)
      /**
       * 每日推荐卡片
       */
      ListItem() {
        ContentButton(`每日推荐`,'符合你口味的新鲜好歌',$r('app.media.bg1'),() => {
          if(this.pageInfos.size() == 0) {
            this.pageInfos.pushPathByName('DailyListPage', null)
          } else {
            this.pageInfos.replacePathByName('DailyListPage', null)
          }
        })
      }

      /**
       * 音乐云盘卡片
       */
      ListItem() {
        ContentButton(`音乐云盘`,`随时随地畅听`,$r('app.media.bg2'),() => {
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

      /**
       * 心动歌单卡片
       */
      ListItem() {
        ContentButton(`心动歌单`,`智能播放`,$r('app.media.bg3'), async () => {
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

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }
}

@Extend(Button) function buttonSty() {
  .type(ButtonType.Normal)
  .width('100%')
  .borderRadius(Constants.RADIUS_IMG)
  .backgroundColor(Color.Transparent)
  // .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
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
        this.ContentSkeleton()
      }
      .width(cardWidth)
      ListItem() {
        this.ContentSkeleton()
      }
      .width(cardWidth)
      ListItem() {
        this.ContentSkeleton()
      }
      .width(cardWidth)

      ListItem().width(5)
    }
    .borderRadius(0)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .width('100%')
  }

  @Builder ContentSkeleton() {
    Button() {
      Column() {
        Column()
          .backgroundColor($r('app.color.background'))
          .alignSelf(ItemAlign.Start)
          .width('70%')
          .borderRadius(Constants.RADIUS_CARD)
          .height(Constants.FONT_SIZE_COMMON + 3)
          .padding(Constants.PADDING_EDGE_DEFAULT)
        Column({ space: 3 }) {
          Column()
            .backgroundColor($r('app.color.background'))
            .alignSelf(ItemAlign.Center)
            .width('80%')
            .borderRadius(Constants.RADIUS_CARD)
            .height(Constants.FONT_SIZE_BAR - 2)
            .padding(Constants.PADDING_EDGE_DEFAULT)
          Column()
            .backgroundColor($r('app.color.background'))
            .alignSelf(ItemAlign.Center)
            .width('80%')
            .borderRadius(Constants.RADIUS_CARD)
            .height(Constants.FONT_SIZE_BAR - 2)
            .padding(Constants.PADDING_EDGE_DEFAULT)
        }
      }
      .padding(Constants.PADDING_EDGE_DEFAULT)
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('100%')
    }
    .buttonSty()
    .backgroundColor($r('app.color.main'))
    .width(cardWidth)
    .height(cardWidth + 30)
  }
}