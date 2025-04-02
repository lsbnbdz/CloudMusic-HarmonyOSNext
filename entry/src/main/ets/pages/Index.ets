import { Explore } from '../components/main/Explore/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { SettingsPage } from './settings/SettingsPage';
import { LocalSongPage } from './local/LocalSongPage';
import { CloudPage } from './playlist/CloudPage';
import { DailyListPage } from './playlist/DailyListPage';
import { SearchPage } from './search/SearchPage';
import { PlayListPage } from './playlist/PlayListPage';
import { ArtistParam, DjRadioParam, PlayListPageParam, WebPageParam } from '../common/entities/local/PageParams';
import { LoginPage } from './login/LoginPage';
import { QrCodeLogin } from './login/QrCodeLogin';
import { WebLogin } from './login/WebLogin';
import { WebPage } from './web/WebPage';
import { UserLists } from '../components/main/UserPlayLists/UserLists';
import { Me } from '../components/main/Me/Me';
import { StorageConstants } from '../common/constants/StorageConstants';
import { TopListPage } from './list/TopListPage';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { DebugPage } from './local/DebugPage';
import BreakpointUtils from '../common/utils/system/BreakpointUtils';
import { ArtistPage } from './artist/ArtistPage';
import { DjRadioPage } from './playlist/DjRadioPage';
import App from '@system.app';

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

  async aboutToAppear(): Promise<void> {
    this.currentHour = new Date().getHours()
    BreakpointUtils.register()
    setTimeout(() => {
      this.tabCurrentIndex = this.index
    }, 1)
    const isFirstLaunch = await PreferencesUtils.getPreferenceValue<boolean>(StorageConstants.USER_PREF, 'isFirstLaunch', true)
    if(isFirstLaunch) {
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, 'isFirstLaunch', false)
    }
  }

  aboutToDisappear(): void {
    BreakpointUtils.unregister()
  }

  onPageShow(): void {
    App.setImageRawDataCacheSize(Constants.CACHE_DISK_MAX_SIZE)
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
          this.pageInfos.pushPathByName('SearchPage', null, true)
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
          TabContent() { Me() }
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
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + 35 })
          .backgroundColor(Color.Transparent)
      }
    }
    .height('100%')
    .width('100%')
    .navBarWidth('50%')
    .navBarPosition(NavBarPosition.Start)
    .mode(this.breakpoint == 'lg' ? NavigationMode.Split : NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .title(this.index === 1 ? this.CategoryTabBar : this.index === 0 ? '发现' : '我的')
    .menus(this.getMenuItems())
    .hideBackButton(true)
    .backgroundColor($r('app.color.background'))
    .navDestination(this.PageMap)
    .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: Color.Transparent })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SettingsPage') {
      SettingsPage()
    }
    else if(name === 'LocalSongPage') {
      LocalSongPage()
    }
    else if(name === 'CloudPage') {
      CloudPage()
    }
    else if(name === 'DailyListPage') {
      DailyListPage()
    }
    else if(name === 'SearchPage') {
      SearchPage()
    }
    else if(name === 'PLayListPage') {
      PlayListPage({ param: param as PlayListPageParam })
    }
    else if(name === 'ArtistPage') {
      ArtistPage({ param: param as ArtistParam })
    }
    else if(name === 'DjRadioPage') {
      DjRadioPage({ param: param as DjRadioParam})
    }
    else if(name === 'LoginPage') {
      LoginPage()
    }
    else if(name === 'QrCodeLogin') {
      QrCodeLogin()
    }
    else if(name === 'WebLogin') {
      WebLogin()
    }
    else if(name === 'WebPage') {
      WebPage({ param: param as WebPageParam })
    }
    else if(name == 'TopListPage') {
      TopListPage()
    }
    else if(name == 'DebugPage') {
      DebugPage()
    }
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