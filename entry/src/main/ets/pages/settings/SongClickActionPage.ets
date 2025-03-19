import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"

/**
 * 歌曲卡片点击操作
 * Sheet
 */
@Component
export struct SongClickActionPage {
  @StorageLink(StorageConstants.SONG_CLICK_ACTION) @Watch('changeActionType') songClickAction: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0

  changeActionType() {
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.SONG_CLICK_ACTION, this.songClickAction)
  }

  build() {
    NavDestination() {
      Column({ space: 30 }) {
        this.SettingItem(0, '点击或长按弹出歌曲信息菜单')
        this.SettingItem(1, '点击直接播放当前歌曲（单首播放）\n长按弹出歌曲信息菜单')
        this.SettingItem(2, '点击直接播放当前歌曲（随歌单一同播放）\n长按弹出歌曲信息菜单')
      }
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT, top: Constants.PADDING_EDGE_TEXT })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .title('歌曲卡片点击模式')
    .backgroundColor($r('app.color.background'))
  }

  @Builder SettingItem(index: number, text: string) {
    Row({ space: 10 }) {
      Radio({ value: `${index}` , group: 'clickAction' })
        .checked(this.songClickAction == index)
        .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
        .onChange((isChecked) => {
          if(isChecked) {
            this.songClickAction = index
          }
        })
      Text(text)
        .textStyle()
    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}

@Extend(Text) function textStyle() {
  .fontSize(16)
  .fontWeight(FontWeight.Bold)
  .width('100%')
  .textAlign(TextAlign.Start)
}