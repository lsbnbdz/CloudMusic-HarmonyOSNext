import { UserPlayLists } from "./UserPlayLists";
import { UserDjRadioList } from "./UserDjRadioList";
import Constants from "../../constants/Constants";

/**
 * 用户歌单
 */
@Component
export struct UserLists {
  tabsController: TabsController = new TabsController()
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @Link @Watch('updateIndex') categoryTabIndex: number

  updateIndex() {
    this.tabsController.changeIndex(this.categoryTabIndex)
  }

  build() {
    Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
      Tabs({ controller: this.tabsController }) {
        TabContent() {
          UserPlayLists()
        }

        TabContent() {
          UserDjRadioList()
        }
      }
      .barHeight(0)
      .width('100%')
      .height('100%')
      .onAnimationStart((from, target) => {
        this.categoryTabIndex = target
      })
    }
    .width('100%')
    .height('100%')
  }
}

