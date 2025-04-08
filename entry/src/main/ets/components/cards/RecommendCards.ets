import { setHeartMode } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/playlist/PlayList"
import { playNext, playQueue } from "../../common/functions/play/playControl"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { DateUtil, ToastUtil } from "@pura/harmony-utils"


const cardRadius: number = 5
const cardHeight: number = 225
const cardWidth: number = 180

@Builder function ContentButton(firText:string, secText:string, imgUrl:ResourceStr, onClick?: () => void, showDate: boolean = false) {
  Stack({ alignContent: Alignment.Center }) {
    Column() {
      Text(`${firText}`)
        .width('100%')
        .textStyle(Constants.FONT_SIZE_TITLE + 3, true)
        .padding(Constants.PADDING_EDGE_DEFAULT)
        .textShadow({ radius: 15 })
      Text(`${secText}`)
        .width('100%')
        .textStyle(Constants.FONT_SIZE_COMMON - 3)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
        .textShadow({ radius: 5 })
        .borderRadius({ bottomLeft: cardRadius, bottomRight: cardRadius })
        .height(Constants.FONT_SIZE_COMMON * 2)
        .backdropBlur(BlurStyle.Regular)
    }
    .width(cardWidth - 20)
    .height(cardHeight - 20)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundImage(imgUrl)
    .backgroundImageSize(ImageSize.Cover)
    .borderRadius(Constants.RADIUS_IMG)
    .shadow({ radius: 10, type: ShadowType.BLUR, offsetX: 10, offsetY: 10 })

    if(showDate) {
      Text(`${DateUtil.getTodayStr('dd')}`)
        .width('100%')
        .fontSize(Constants.FONT_SIZE_TITLE * 2)
        .textShadow({ radius: 5 })
        .fontWeight(FontWeight.Bolder)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Transparent)
    }
  }
  .backgroundColor(Color.Transparent)
  .width(cardWidth)
  .height(cardHeight)
  .onClick(onClick)
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
}

@Component
export struct RecommendCards {
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @Prop isLogged: boolean
  @Prop breakpoint: string = 'sm'
  @State isLoadingSongs: boolean = false
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = true

  build() {
    List() {
      ListItem().width(10)
      if(this.validApiUrl) {
        /**
         * 每日推荐卡片
         */
        ListItem() {
          ContentButton(`每日推荐`,'符合你口味的新鲜好歌',$r('app.media.bg_daily'),() => {
            if(this.pageInfos.size() === 0) {
              this.pageInfos.pushPathByName('DailyListPage', null, this.breakpoint === 'lg' ? false : true)
            } else {
              this.pageInfos.replacePathByName('DailyListPage', null)
            }
          }, true)
        }

        /**
         * 私人FM
         */
        ListItem() {
          ContentButton(`私人FM`,`多种模式随心播放`,$r('app.media.bg_fm'), async () => {
            if(!this.isLoadingSongs) {
              this.isLoadingSongs = true
              try {
                AppStorage.setOrCreate(StorageConstants.IS_PERSONAL_FM, true)
                await PlayQueueUtils.cleanQueue()
                playNext()
              } catch (e) {
                ToastUtil.showToast('获取私人FM曲目失败')
              } finally {
                setTimeout(() => {
                  this.isLoadingSongs = false
                }, 1000)
              }
            } else {
              ToastUtil.showToast('正在加载, 请稍后')
            }
          })
        }

        /**
         * 音乐云盘卡片
         */
        ListItem() {
          ContentButton(`音乐云盘`,`享受云端曲目`,$r('app.media.bg_cloud'),() => {
            if(this.isLogged) {
              if(!this.pageInfos.getAllPathName().includes('CloudPage')) {
                this.pageInfos.pushPathByName('CloudPage', null, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
              } else {
                this.pageInfos.replacePath({ name: 'CloudPage', param: null }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
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
          ContentButton(`心动歌单`,`智能播放`,$r('app.media.bg_heart'), async () => {
            if(this.isLogged) {
              if(!this.isLoadingSongs) {
                try {
                  this.isLoadingSongs = true
                  ToastUtil.showToast('开始播放心动歌单')
                  await setHeartMode(PlayQueueUtils.getCurrentSong().id, this.playLists[0].id)
                  playQueue(0)
                } catch (e) {
                  ToastUtil.showToast('获取心动歌单失败: ' + e.message)
                } finally {
                  setTimeout(() => {
                    this.isLoadingSongs = false
                  }, 1000)
                }
              } else {
                ToastUtil.showToast('正在加载, 请稍后')
              }
            } else {
              ToastUtil.showToast('请登录后再试')
            }
          })
        }
      }

      /**
       * 本地曲库
       */
      ListItem() {
        ContentButton(`本地曲库`,`随时随地畅听`,$r('app.media.bg_local'),() => {
          if(this.pageInfos.size() === 0) {
            this.pageInfos.pushPathByName('LocalSongPage', null, this.breakpoint === 'lg' ? false : true)
          } else {
            this.pageInfos.replacePathByName('LocalSongPage', null)
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
  .borderRadius(cardRadius)
  .backgroundColor(Color.Transparent)
}

@Extend(Text) function textStyle(size: number, isBold: boolean = false) {
  .fontSize(size)
  .fontColor(Color.White)
  .fontWeight(isBold ? FontWeight.Bold : FontWeight.Normal)
}