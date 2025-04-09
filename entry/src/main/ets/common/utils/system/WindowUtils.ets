import { window } from '@kit.ArkUI'
import { LogUtil } from '@pura/harmony-utils'

const TAG = '[OrientationUtils] '

class WindowUtils {
  windowClass: window.Window | undefined = undefined
  flag: number = 0

  init(data: window.Window) {
    this.windowClass = data
  }

  getInstance(): window.Window {
    return this.windowClass!
  }

  toggleStatusBar(toggle: boolean) {
    this.windowClass!.setWindowSystemBarEnable(toggle ? ['status'] : [])
  }

  setOrientation(target: window.Orientation) {
    if(canIUse("SystemCapability.WindowManager.WindowManager.Core")) {
      try {
        let orientation = target
        if(target === window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED) this.flag = 1
        else this.flag = 0
        if(this.windowClass) {
          this.windowClass.setPreferredOrientation(orientation)
        }
      } catch (e) {
        LogUtil.error(TAG + 'set orientation error: ' + e.message + '\n' + e.stack)
      }
    }
  }

  getOrientation(): window.Orientation {
    if(this.windowClass) {
      return this.windowClass.getPreferredOrientation()
    } else return window.Orientation.UNSPECIFIED
  }
}

const windowUtils: WindowUtils = new WindowUtils()
export default windowUtils as WindowUtils