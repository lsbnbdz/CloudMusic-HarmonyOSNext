export class BreakpointType<T> {
  sm: T
  md: T
  lg: T

  constructor(sm: T, md: T, lg: T) {
    this.sm = sm
    this.md = md
    this.lg = lg
  }

  getValue(currentWidthBreakpoint: string): T {
    if(currentWidthBreakpoint === 'sm') {
      return this.sm
    }
    if(currentWidthBreakpoint === 'md') {
      return this.md
    }
    if(currentWidthBreakpoint === 'lg') {
      return this.lg
    }
    return this.sm
  }
}