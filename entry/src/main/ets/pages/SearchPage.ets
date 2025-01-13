import { EmitterUtil, LogUtil, ToastUtil } from '@pura/harmony-utils';
import { BottomPlayController } from '../components/play/BottomPlayController';
import { CommonCircleButton } from '../components/buttons/CircleButton';
import { router } from '@kit.ArkUI';
import { SearchPlayListsList } from '../components/lists/SearchPlayListsList';
import Constants from '../common/constants/Constants';
import { SearchSongsList } from '../components/lists/SearchSongsList';

/**
 * 歌曲列表页（搜索结果）
 */
const TAG = "[SearchPage] "
@Entry
@Component
struct SearchPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State tabPageIndex: number = 0
  @State searchKeyword: string = ''
  hasAnimation: boolean | undefined = false
  private tabsController: TabsController = new TabsController()

  pageTransition() {
    PageTransitionEnter({ duration: 100, curve: Curve.EaseIn })
    PageTransitionExit({ duration: 100, curve: Curve.EaseOut })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if(this.searchKeyword != '') {
            Column({ space: 10 }) {
              this.TabBar()
              Tabs({ controller: this.tabsController }) {
                TabContent() { SearchSongsList({ searchKeyword: this.searchKeyword }) }
                TabContent() { SearchPlayListsList({ searchKeyword: this.searchKeyword }) }
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
          this.Head()
        }
        .height('100%')

      BottomPlayController()
        .padding({ left: 10, right: 10, bottom: px2vp(this.bottomRectHeight)})
        .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
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
    .padding({ top: px2vp(this.topRectHeight) + 60 })
  }

  @Builder
  Head() {
    Row({ space: 20 }) {
      CommonCircleButton({ ButtonImageName:'ic_public_back' })
        .onClick(() => {
          router.back()
        })
      Search({
        placeholder: '搜索内容',
        icon: '/resources/base/media/ic_public_search_filled.svg',
      })
        .sharedTransition('search_component', {
            duration: 300,
            curve: Curve.Friction
          })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onSubmit(async (value) => {
          this.searchKeyword = value
          EmitterUtil.post(Constants.EMITTER_SEARCH, value)
          if(!value) {
            ToastUtil.showToast('请输入搜索内容')
          }
        })
    }
    .opacity(0.95)
    .backdropBlur(50)
    .padding({ left: 10, right: 20, top: px2vp(this.topRectHeight) })
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}