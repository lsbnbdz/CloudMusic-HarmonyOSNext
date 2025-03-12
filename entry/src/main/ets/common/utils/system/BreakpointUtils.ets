import mediaQuery from '@ohos.mediaquery'
import { StorageConstants } from '../../constants/StorageConstants'

class BreakpointUtils {
  private currentBreakpoint: string = 'sm'
  private smListener?: mediaQuery.MediaQueryListener
  private mdListener?: mediaQuery.MediaQueryListener
  private lgListener?: mediaQuery.MediaQueryListener
  private xlListener?: mediaQuery.MediaQueryListener

  private updateCurrent(breakpoint: string) {
    if (this.currentBreakpoint !== breakpoint) {
      this.currentBreakpoint = breakpoint
      AppStorage.setOrCreate(StorageConstants.BREAKPOINT, this.currentBreakpoint)
    }
  }

  private isBreakpointSM = (mediaQueryResult:mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrent('sm')
    }
  }

  private isBreakpointMD = (mediaQueryResult:mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrent('md')
    }
  }

  private isBreakpointLG = (mediaQueryResult:mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrent('lg')
    }
  }

  public register() {
    this.smListener = mediaQuery.matchMediaSync('(320vp<=width<600vp)')
    this.smListener.on('change', this.isBreakpointSM)
    this.mdListener = mediaQuery.matchMediaSync('(600vp<=width<840vp)')
    this.mdListener.on('change', this.isBreakpointMD)
    this.lgListener = mediaQuery.matchMediaSync('(840vp<=width)')
    this.lgListener.on('change', this.isBreakpointLG)
  }

  public unregister() {
    this.smListener?.off('change', this.isBreakpointSM)
    this.mdListener?.off('change', this.isBreakpointMD)
    this.lgListener?.off('change', this.isBreakpointLG)
  }
}

const breakpointUtils = new BreakpointUtils()
export default breakpointUtils as BreakpointUtils