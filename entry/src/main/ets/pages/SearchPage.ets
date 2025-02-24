import { EmitterUtil, ToastUtil } from '@pura/harmony-utils';
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import { SearchPlayListsList } from '../components/lists/SearchPlayListsList';
import { SearchSongsList } from '../components/lists/SearchSongsList';
import { EmitterConstants } from '../common/constants/EmitterConstants';
import Constants from '../common/constants/Constants';
import { StorageConstants } from '../common/constants/StorageConstants';
import { resourceManager } from '@kit.LocalizationKit';

/**
 * 歌曲列表页（搜索结果）
 */
const TAG = "[SearchPage] "

@Component
export struct SearchPage {
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @State tabPageIndex: number = 0
  @State searchKeyword: string = ''
  private tabsController: TabsController = new TabsController()

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if(this.searchKeyword != '') {
            Column({ space: 10 }) {
              this.TabBar()
              Tabs({ controller: this.tabsController }) {
                TabContent() { SearchSongsList({ searchKeyword: this.searchKeyword }) }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                TabContent() { SearchPlayListsList({ searchKeyword: this.searchKeyword }) }.expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              }
              .layoutWeight(1)
              .onChange((index) => {
                this.tabPageIndex = index
              })
              .scrollable(false)
              .barHeight(0)
            }
            .height('100%')
            .width('100%')
          }
        }
        .height('100%')

        if(this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_PHONE) {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .backgroundColor($r('app.color.background'))
    .title(this.Head())
  }

  /**
   * TabBar
   */
  @Builder
  TabBarButton(content: string, toIndex: number) {
    Button() {
      Text(content)
        .fontColor(this.tabPageIndex == toIndex ? '#ffee6f6f' : $r('app.color.reverse'))
    }
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor(Color.Transparent)
    .animation({ duration: 200 })
    .onClick(() => {
      this.tabsController.changeIndex(toIndex)
    })
  }

  @Builder
  TabBar() {
    Row({ space: 5 }) {
      this.TabBarButton('单曲', 0)
      this.TabBarButton('歌单', 1)
    }
    .width('80%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  Head() {
    Column() {
      Search({
        placeholder: '搜索内容',
        icon: '/resources/base/media/ic_public_search_filled.svg',
      })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onSubmit(async (value) => {
          this.searchKeyword = value
          EmitterUtil.post(EmitterConstants.EMITTER_SEARCH, value)
          if (!value) {
            ToastUtil.showToast('请输入搜索内容')
          }
        })
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT })
  }
}