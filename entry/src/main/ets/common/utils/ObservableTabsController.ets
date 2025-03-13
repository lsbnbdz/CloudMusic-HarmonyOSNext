export class ObservableTabsController {
  private tabsController: TabsController = new TabsController()

  changeIndex(index: number){
    this.tabsController.changeIndex(index)
  }
  // 获取原始 Scroller（按需）
  getTabsController(): TabsController {
    return this.tabsController;
  }
}