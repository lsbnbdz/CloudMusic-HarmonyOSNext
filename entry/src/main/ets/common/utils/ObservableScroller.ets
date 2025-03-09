export class ObservableScroller {
  private scroller: Scroller = new Scroller();


  scrollToTop() {
    this.scroller.scrollEdge(Edge.Top);
  }

  scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom);
  }

  // 获取原始 Scroller（按需）
  getScroller(): Scroller {
    return this.scroller;
  }
}