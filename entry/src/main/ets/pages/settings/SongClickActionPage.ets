import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { Song } from "../../common/entities/song/SongsResult"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import VibratorUtils from "../../common/utils/system/VibratorUtils"
import { SongCard } from "../../components/cards/SongCard"


/**
 * 歌曲卡片点击操作
 * Sheet
 */
@Component
export struct SongClickActionPage {
  @StorageLink(StorageConstants.SONG_CLICK_ACTION) @Watch('changeActionType') clickAction: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isShowMenu: boolean = false
  @State egSong: Song = {
    id: -1,
    name: '歌曲名',
    artists: [{
      id: -1,
      name: '歌手名'
    }],
    duration: 0,
    alias: [],
    fee: 1
  }

  changeActionType() {
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.SONG_CLICK_ACTION, this.clickAction)
  }

  build() {
    NavDestination() {
      Column({ space: 10 }) {
        Text('歌曲卡片样式')
          .titleStyle()
        Stack() {
          SongCard({
            picUrl: $r('app.media.ic_files_audio'),
            song: this.egSong,
            isShowMenu: false
          })
          Button()
            .backgroundColor(Color.Transparent)
            .width('100%')
            .height(60)
            .type(ButtonType.Normal)
            .bindContextMenu(this.isShowMenu, this.ClickMenu, { onDisappear: () => { this.isShowMenu = false }})
            .gesture(
              LongPressGesture({
                duration: 500
              }).onAction(() => {
                VibratorUtils.startCount('sharp', 1, 100)
                this.isShowMenu = true
              })
            )
            .onClick(async () => {
              if(this.clickAction == 0) {
                this.isShowMenu = true
              } else if(this.clickAction == 1) {
                ToastUtil.showToast('单曲播放')
              } else {
                ToastUtil.showToast('随歌单一同播放')
              }
            })
        }

        Text('卡片点击操作')
          .titleStyle()
        this.SettingItem(0, '单击或长按显示歌曲信息菜单')
        this.SettingItem(1, '单击后直接播放（单首播放）\n长按显示歌曲信息菜单')
        this.SettingItem(2, '单击后直接播放（随歌单一同播放）\n长按显示歌曲信息菜单')
      }
      .padding({
        left: 20,
        right: 20,
        bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT,
        top: Constants.PADDING_EDGE_DEFAULT
      })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .title('歌曲卡片设置')
    .backgroundColor($r('app.color.background'))
  }

  @Builder SettingItem(index: number, text: string) {
    Row({ space: 10 }) {
      Radio({ value: `${index}` , group: 'clickAction' })
        .checked(this.clickAction == index)
        .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
        .onChange((isChecked) => {
          if(isChecked) {
            this.clickAction = index
          }
        })
      Text(text)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .lineHeight(20)
    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .itemStyle()
  }

  @Builder ClickMenu() {
    Menu() {
      MenuItem() {
        Text('歌曲信息菜单')
          .titleStyle()
          .padding({ top: 10, bottom: 10 })
      }
    }
    .constraintSize({
      minWidth: 100,
      maxWidth: 200
    })
    .padding(Constants.PADDING_EDGE_DEFAULT)
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }

}

@Extend(Text) function titleStyle() {
  .fontColor($r('app.color.reverse'))
    .fontSize(Constants.FONT_SIZE_COMMON)
    .fontWeight(FontWeight.Bold)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT })
    .width('100%')
}