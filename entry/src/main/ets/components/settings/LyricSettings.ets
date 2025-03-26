import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { LyricStyle, LyricStyleItem } from "../../common/entities/Settings";
import { changeSettings } from "../../common/functions/app/settings";

@Component
export struct LyricTranslate {
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyleItem

  build() {
    Row() {
      Text('启用歌词翻译')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Toggle({ type: ToggleType.Switch, isOn: this.lyricStyle.mode == 1 })
        .height(24)
        .width(48)
        .onChange((isOn) => {
          if(!isOn) {
            this.lyricStyle.mode = 0
          } else {
            this.lyricStyle.mode = 1
          }
          changeSettings(StorageConstants.LYRIC_STYLE, this.lyricStyle)
        })
        .selectedColor($r('app.color.app_red'))
    }
    .height(Constants.HEIGHT_SETTINGS_ITEM)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Component
export struct SetLyricSize {
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyleItem
  @State style: LyricStyle = LyricStyleItem

  aboutToAppear(): void {
    this.style = this.lyricStyle
  }

  build() {
    Column({ space: 5 }) {
      Row() {
        Text('歌词字体大小')
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Text(this.lyricStyle.size.toString())
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

      Slider({
        value: this.style.size,
        min: 10,
        max: 30
      })
        .selectedColor($r('app.color.app_red'))
        .width('100%')
        .onChange((value, mode) => {
          if(mode == SliderChangeMode.Moving) {
            this.style.size = value
          }
          this.lyricStyle.size = value
          this.updateLyricStyle()
        })

      Text('效果预览')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding(Constants.PADDING_EDGE_DEFAULT)

      Column({ space: 15 }) {
        Text('When your dreams come alive you\'re unstoppable')
          .lyricStyle(this.lyricStyle.size)
        Text('我一路向北 离开有你的季节')
          .lyricStyle(this.lyricStyle.size).opacity(1)
        Text('君と集まって星座になれたら')
          .lyricStyle(this.lyricStyle.size)
      }
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    }

  }

  updateLyricStyle() {
    this.style = this.lyricStyle
    changeSettings(StorageConstants.LYRIC_STYLE, this.style)
  }
}

@Extend(Text) function lyricStyle(size: number) {
  .width('100%')
  .textAlign(TextAlign.Center)
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .opacity(0.35)
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
}
