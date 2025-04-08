import { Explore } from '../components/main/Explore/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import {
  AlbumParam,
  ArtistParam,
  CommonParam } from '../common/entities/local/PageParams';
import { UserLists } from '../components/main/UserPlayLists/UserLists';
import { Me } from '../components/main/Me/Me';
import { StorageConstants } from '../common/constants/StorageConstants';
import BreakpointUtils from '../common/utils/system/BreakpointUtils';
import { EmitterUtil } from '@pura/harmony-utils';
import { EmitterConstants } from '../common/constants/EmitterConstants';
import { PageMap } from '../common/model/PageMap';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  tabController: TabsController = new TabsController()

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.DEFAULT_PAGE_INDEX) index: number = 0
  @State currentHour: number = 0
  @State tabCurrentIndex: number = 0
  @State categoryTabIndex: number = 0
  @State toolBarHeight: number = 0

  async aboutToAppear(): Promise<void> {
    BreakpointUtils.register()
    setTimeout(() => {
      this.tabCurrentIndex = this.index
    }, 1)
    // const isFirstLaunch = await PreferencesUtils.getPreferenceValue<boolean>(StorageConstants.USER_PREF, 'isFirstLaunch', true)
    // if(isFirstLaunch) {
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, 'isFirstLaunch', false)
    // }
    EmitterUtil.onSubscribe(EmitterConstants.PUSH_PAGE, <T extends ArtistParam | AlbumParam>(param: CommonParam<T>) => {
      if(param.remove) {
        this.pageInfos.removeByName(param.pageName)
      }
      this.pageInfos.pushPathByName(param.pageName, param.param)
    })
  }

  aboutToDisappear(): void {
    BreakpointUtils.unregister()
  }

  onPageShow(): void {
    this.currentHour = new Date().getHours()
  }

  private getMenuItems(): NavigationMenuItem[] {
    let items: NavigationMenuItem[] = []
    if(this.index === 0 || this.index === 1) {
      items.push({
        value: 'Search',
        icon: $r('app.media.ic_public_search_filled'),
        action: () => {
          this.pageInfos.clear()
          this.pageInfos.pushPathByName('SearchPage', null, (this.breakpoint === 'lg') && this.pageInfos.size() === 0 ? false : true)
        }
      })
    }
    if(this.index === 2) {
      items.push({
        value: 'Settings',
        icon: $r('app.media.ic_public_settings'),
        action: () => {
          AppStorage.setOrCreate('isShowSettings', true)
        }
      })
    }
    // if(this.index == 1) {
    //   items.unshift({
    //     value: 'Add',
    //     icon: $r('app.media.ic_public_add_filled'),
    //     action: () => {
    //       this.addPlayListController.open()
    //     }
    //   })
    // }
    return items
  }

  async build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ controller: this.tabController, index: this.tabCurrentIndex }) {
          TabContent() { Explore({ currentHour: this.currentHour }) }
          TabContent() { UserLists({ categoryTabIndex: this.categoryTabIndex }) }
          TabContent() { Me({ breakpoint: this.breakpoint }) }
        }
        .height('100%')
        .width('100%')
        .barHeight(0)
        .edgeEffect(EdgeEffect.None)
        .animationDuration(300)
        .onAnimationStart((from, target) => {
          this.index = target
        })
        .onChange((index) => { this.index = index })

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + this.toolBarHeight })
          .backgroundColor(Color.Transparent)
      }
    }
    .height('100%')
    .width('100%')
    .navBarWidth('50%')
    .navBarPosition(NavBarPosition.Start)
    .mode((this.breakpoint == 'lg' && this.pageInfos.size() > 0) ? NavigationMode.Split : NavigationMode.Stack)
    .enableModeChangeAnimation(true)
    .titleMode(NavigationTitleMode.Mini)
    .title(this.index === 1 ? this.CategoryTabBar : this.index === 0 ? '发现' : '我的')
    .menus(this.getMenuItems())
    .hideBackButton(true)
    .backgroundColor($r('app.color.background'))
    .navDestination(PageMap)
    .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: Color.Transparent })
    .animation({ duration: 500, curve: Curve.Smooth })
  }

  @Builder ToolBar() {
    Row() {
      this.ToolBarItem(0, $r('app.media.ic_gallery_discover'), $r('app.media.ic_gallery_discover_filled'), '发现')
      this.ToolBarItem(1, $r('app.media.ic_public_drawer'), $r('app.media.ic_public_drawer_filled'),'播单')
      this.ToolBarItem(2, $r('app.media.ic_public_contacts'), $r('app.media.ic_public_contacts_filled'), '我的')
    }
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
    .onAreaChange((oldArea, newArea) => {
      this.toolBarHeight = newArea.height as number
    })
  }

  @Builder ToolBarItem(index: number, icon: ResourceStr, activeIcon: ResourceStr, text: string) {
    Column({ space: 3 }) {
      Image(this.index == index ? activeIcon : icon)
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor(this.index == index ? $r('app.color.app_red') : Color.Gray)
      Text(text)
        .fontSize(Constants.FONT_SIZE_BAR)
        .fontColor(this.index == index ? $r('app.color.app_red') : Color.Gray)
    }
    .layoutWeight(1)
    .onClick(() => {
      this.tabController.changeIndex(index)
    })
  }

  @Builder CategoryTabBar() {
    Column() {
      Row({ space: Constants.PADDING_EDGE_TEXT }) {
        this.CategoryBarButtonItem('歌单', 0)
        this.CategoryBarButtonItem('播客', 1)
      }
      .backgroundColor($r('app.color.main'))
      .borderRadius(Constants.RADIUS_CARD)
      .justifyContent(FlexAlign.Center)
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder CategoryBarButtonItem(title: string, index: number) {
    Button() {
      Text(title)
        .fontSize(18)
        .fontColor(this.categoryTabIndex === index ? $r('app.color.app_red') : Color.Gray)
        .fontWeight(FontWeight.Bold)
    }
    .width(50)
    .backgroundColor(Color.Transparent)
    .padding(5)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
    .onClick(() => { this.categoryTabIndex = index })
  }
}