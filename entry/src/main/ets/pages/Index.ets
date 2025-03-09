import { Explore } from '../components/main/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { SettingsPage } from './SettingsPage';
import { CachedPage } from './CachedPage';
import { CloudPage } from './CloudPage';
import { DailyListPage } from './DailyListPage';
import { SearchPage } from './SearchPage';
import { PlayListPage } from './PlayListPage';
import { PlayListPageParam, WebPageParam } from '../common/entities/PageParams';
import { LoginPage } from './login/LoginPage';
import { QrCodeLogin } from './login/QrCodeLogin';
import { WebLogin } from './login/WebLogin';
import { WebPage } from './WebPage';
import { UserPlayLists } from '../components/main/UserPlayLists';
import { Me } from '../components/main/Me';
import { resourceManager } from '@kit.LocalizationKit';
import { StorageConstants } from '../common/constants/StorageConstants';
import { WarrantyDialog } from '../components/dialog/WarrantyDialog';
import { TopListPage } from './TopListPage';
import { ApiDialog } from '../components/dialog/ApiDialog';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { DebugPage } from './DebugPage';
import { AddPlayListDialog } from '../components/dialog/AddPlayListDialog';
import { LengthMetrics } from '@kit.ArkUI';
import { myCustomTitle } from '../components/custom/CustomTitle';

@Entry
@Component
struct Index {

  @State titleOpacity: number[] = [1, 1, 1]
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  apiDialogController: CustomDialogController = new CustomDialogController({
    builder: ApiDialog(),
    autoCancel: false
  })

  addPlayListController: CustomDialogController = new CustomDialogController({
    builder: AddPlayListDialog(),
    autoCancel: true
  })

  tabController: TabsController = new TabsController()

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @StorageProp(StorageConstants.DEFAULT_PAGE_INDEX) index: number = 0
  @StorageProp(StorageConstants.VALID_API_URL) @Watch('checkApi') validApiUrl: boolean = true
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  private paddingStart: LengthMetrics = LengthMetrics.vp(16);
  private paddingEnd: LengthMetrics = LengthMetrics.vp(16);

  private getMenuItems(): NavigationMenuItem[] {
    let items: NavigationMenuItem[] = []
    if(this.index == 0 || this.index == 1) {
      items.push({
        value: 'Search',
        icon: $r('app.media.ic_public_search_filled'),
        action: () => {
          this.pageInfos.clear()
          this.pageInfos.pushPathByName('SearchPage', null, true)
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

  checkApi() {
    if(!this.validApiUrl) {
      this.apiDialogController.open()
    }
  }

  async aboutToAppear(): Promise<void> {
    this.checkApi()
    const isFirstLaunch = await PreferencesUtils.getPreferenceValue<boolean>(StorageConstants.USER_PREF, 'isFirstLaunch', true)
    if(isFirstLaunch) {
      this.apiDialogController.open()
      this.warrantyDialogController.open()
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, 'isFirstLaunch', false)
    }

  }

  async build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ index: this.index, controller: this.tabController }) {
          TabContent() { Explore({ index: this.index, titleOpacity: this.titleOpacity }) }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          TabContent() { UserPlayLists({ index: this.index, titleOpacity: this.titleOpacity }) }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          TabContent() { Me({ index: this.index, titleOpacity: this.titleOpacity }) }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }
        .scrollable(false)
        .animationMode(AnimationMode.NO_ANIMATION)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .height('100%')
        .width('100%')
        .barHeight(0)
        .edgeEffect(EdgeEffect.None)
        .animationDuration(300)

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
      }
    }
    .height('100%')
    .width('100%')
    .navBarWidthRange(['40%', '60%'])
    .navBarPosition(NavBarPosition.Start)
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    // .title(this.index == 0 ? '发现' : this.index == 1 ? '歌单' : '我的')
    .title(myCustomTitle(this.pageInfos, this.titleOpacity, this.index), {
      paddingStart: this.paddingStart,
      paddingEnd: this.paddingEnd,
      barStyle: BarStyle.STACK
    })
    // .menus(this.getMenuItems())
    .hideBackButton(true)
    .hideTitleBar(this.titleOpacity[this.index] == 0 ? true : false)
    // .backgroundColor($r('app.color.background'))
    .backgroundColor('transparent')
    .navDestination(this.PageMap)
    .hideToolBar(true)
    // .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: Color.Transparent })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SettingsPage') {
      SettingsPage()
    }
    else if(name === 'DownloadPage') {
      CachedPage()
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
      this.ToolBarItem(1, $r('app.media.ic_public_drawer'), $r('app.media.ic_public_drawer_filled'),'歌单')
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
        .fillColor(this.index == index ? $r('app.color.blue') : Color.Gray)
      Text(text)
        .fontSize(Constants.FONT_SIZE_BAR)
        .fontColor(this.index == index ? $r('app.color.blue') : Color.Gray)
    }
    .layoutWeight(1)
    .onClick(() => {
      this.tabController.changeIndex(index)
    })
  }
}