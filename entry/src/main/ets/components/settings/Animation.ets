import Constants from "../../common/constants/Constants";
import PreferencesUtils from "../../common/utils/app/PreferencesUtils";

/**
 * 动画开关
 */
@Component
export struct Animation {
  @StorageLink('set-hasAnimation') hasAnimation: boolean = true
  build() {
    Row() {
      Text('歌曲列表动画').LeftText()
      Toggle({ type: ToggleType.Switch, isOn:this.hasAnimation })
        .height(24)
        .width(48)
        .onChange(async () => {
          this.hasAnimation = !this.hasAnimation; AppStorage.setOrCreate('set-hasAnimation',this.hasAnimation)
          await PreferencesUtils.putPreferenceValue('Settings','hasAnimation',this.hasAnimation)
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