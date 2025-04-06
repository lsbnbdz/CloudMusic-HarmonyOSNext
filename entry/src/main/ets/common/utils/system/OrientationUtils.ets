import { window } from '@kit.ArkUI'
import { LogUtil } from '@pura/harmony-utils'

const TAG = '[OrientationUtils] '

class OrientationUtils {
  windowClass: window.Window | undefined = undefined
  init(data: window.Window) {
    this.windowClass = data
  }

  setOrientation(target: window.Orientation) {
    try {
      let orientation = target
      if(this.windowClass) {
        this.windowClass.setPreferredOrientation(orientation)
      }
    } catch (e) {
      LogUtil.error(TAG + 'set orientation error: ' + e.message + '\n' + e.stack)
    }
  }

  getOrientation(): window.Orientation {
    if(this.windowClass) {
      return this.windowClass.getPreferredOrientation()
    } else return window.Orientation.UNSPECIFIED
  }
}

const orientation: OrientationUtils = new OrientationUtils()
export default orientation as OrientationUtils