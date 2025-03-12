export class ObservableScroller {
  private scroller: Scroller = new Scroller();


  scrollToTop() {
    // this.scroller.scrollEdge(Edge.Top);
    this.scroller.scrollTo({
      yOffset: 0,
      xOffset: 0,
      animation: true
    })
  }

  scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom);
  }

  // 获取原始 Scroller（按需）
  getScroller(): Scroller {
    return this.scroller;
  }
}