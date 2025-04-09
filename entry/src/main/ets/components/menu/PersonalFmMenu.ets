import { PlayConstants } from "../../common/constants/PlayConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"

@Builder
export function PersonalFmMenu(personalFmMode: number) {
  Menu() {
    if(personalFmMode !== 0) {
      MenuItem({ content: `- ${PlayConstants.PERSONAL_FM_MODE_NAME[0]} -` })
        .onClick(() => { AppStorage.setOrCreate(StorageConstants.PERSONAL_FM_MODE, 0 )})
    }
    if(personalFmMode !== 1) {
      MenuItem({ content: `- ${PlayConstants.PERSONAL_FM_MODE_NAME[1]} -` })
        .onClick(() => { AppStorage.setOrCreate(StorageConstants.PERSONAL_FM_MODE, 1 )})
    }
    if(personalFmMode !== 2) {
      MenuItem({ content: `- ${PlayConstants.PERSONAL_FM_MODE_NAME[2]} -` })
        .onClick(() => { AppStorage.setOrCreate(StorageConstants.PERSONAL_FM_MODE, 2 )})
    }
    MenuItem({ content: '关闭私人FM' })
      .onClick(() => { AppStorage.setOrCreate(StorageConstants.IS_PERSONAL_FM, false) })
  }
}