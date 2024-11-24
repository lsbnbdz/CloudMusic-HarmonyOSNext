import { SettingsHead } from '../components/head/SettingsHead'

@Entry
@Component
struct Settings {
  build() {
    Column() {
      SettingsHead()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.main'))
  }
}