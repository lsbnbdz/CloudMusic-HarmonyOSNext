import Constants from "../../common/constants/Constants"
import { PlayConstants } from "../../common/constants/PlayConstants"
import { QualityType } from "../../common/entities/SongDownload"
import PreferencesUtils from "../../common/utils/app/PreferencesUtils"

/**
 * 设置播放音质
 */
@Component
export struct SetPlayQuality {
  @StorageLink('set-playQuality') playQuality:QualityType = "standard"
  @State selected:number | undefined = 0

  async aboutToAppear(): Promise<void> {
    this.selected = await AppStorage.get('set-playQuality')
  }
  build() {
    Row() {
      Text('在线播放音质').LeftText()
      Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
        .selected(this.selected)
        .value(this.selected ? PlayConstants.QUALITY_NAME[this.selected] : '标准')
        .width(100)
        .height(Constants.HEIGHT_SELECT)
        .onSelect((index: number) => {
          AppStorage.setOrCreate('set-playQuality',index)
          PreferencesUtils.putPreferenceValue('Settings', 'playQuality', index)
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}

@Extend(Text) function LeftText() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}