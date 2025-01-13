import PreferencesUtils from "../utils/PreferencesUtils";

/**
 * 动画开关
 */
@Component
export struct Animation {
  @StorageLink('set-hasAnimation') hasAnimation: boolean = true
  build() {
    Row() {
      Text('歌曲列表动画').LeftText()
      Toggle({ type: ToggleType.Switch, isOn:this.hasAnimation }).height(24).width(48)
        .onChange(async () => { this.hasAnimation = !this.hasAnimation; AppStorage.setOrCreate('set-hasAnimation',this.hasAnimation); await PreferencesUtils.putPreferenceValue('Settings','hasAnimation',this.hasAnimation)})
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding({ left:30, right: 30})
  }
}

@Extend(Text) function LeftText() {
  .fontSize(16)
  .fontWeight(FontWeight.Bold)
}