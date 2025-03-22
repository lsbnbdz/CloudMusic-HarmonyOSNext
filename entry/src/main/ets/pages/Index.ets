import { Explore } from '../components/main/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import { SettingsPage } from './settings/SettingsPage';
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
import { StorageConstants } from '../common/constants/StorageConstants';
import { WarrantyDialog } from '../components/dialog/WarrantyDialog';
import { TopListPage } from './TopListPage';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { DebugPage } from './DebugPage';
import { AddPlayListDialog } from '../components/dialog/AddPlayListDialog';
import { LengthMetrics, promptAction } from '@kit.ArkUI';
import { myCustomTitle } from '../components/custom/CustomTitle';
import BreakpointUtils from '../common/utils/system/BreakpointUtils';
import { ObservableScroller } from '../common/utils/ObservableScroller';
import { ObservableTabsController } from '../common/utils/ObservableTabsController';

const _arrStr: string[] = ['发现', '歌单', '我的'];
const _subArrStr: string[] = ['所有', '自建', '收藏'];

@Entry
@Component
struct Index {

  @State titleOpacity: number[] = [1, 1, 1]
  @State subTitleOpacity: number[] = [1, 1, 1]

  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()

  tabController: TabsController = new TabsController()

  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.DEFAULT_PAGE_INDEX) index: number = 0
  @State tabCurrentIndex: number = 0
  @State subIndex: number = 0
  @State observableTabsController: ObservableTabsController = new ObservableTabsController()

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

  async aboutToAppear(): Promise<void> {
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

  async build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ index: this.index, controller: this.tabController }) {
          TabContent() { Explore({ index: this.index, titleOpacity: this.titleOpacity }) }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          TabContent() { UserPlayLists({ index: this.index, subTitleOpacity: this.subTitleOpacity, subIndex: this.subIndex, observableTabsController: this.observableTabsController }) }
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
    .navBarWidth('50%')
    .navBarPosition(NavBarPosition.Start)
    .mode(this.breakpoint == 'lg' ? NavigationMode.Split : NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    // .title(this.index == 0 ? '发现' : this.index == 1 ? '歌单' : '我的')
    .title(this.myCustomTitle(this.index), {
      paddingStart: this.paddingStart,
      paddingEnd: this.paddingEnd,
      barStyle: BarStyle.STACK
    })
    // .menus(this.getMenuItems())
    .hideBackButton(true)
    .hideTitleBar(this.titleOpacity[this.index] == 0 ? true : false)
    .backgroundColor($r('app.color.background'))
    // .backgroundColor('transparent')
    .navDestination(this.PageMap)
    .hideToolBar(true)
    // .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: Color.Transparent })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SettingsPage') {
      SettingsPage()
    }
    else if(name === 'CachedPage') {
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

  @Builder
  myCustomTitle(index: number){
    Stack({ alignContent: Alignment.Bottom }){

      Row(){}
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])
      .height('100%')
      .width('100%')
      // .backgroundBlurStyle(BlurStyle.BACKGROUND_THICK)
      .backgroundColor('transparent')
      // .linearGradient({
      //   colors: [
      //     ['transparent', 0.00],
      //     [$r('app.color.title_background'), 1.00]
      //   ],
      //   angle: 0
      // })
      .linearGradientBlur(10, {
        fractionStops: [
          [0.00, 0.00],
          [0.40, 0.10],
          [1.00, 1.00]
        ],
        direction: GradientDirection.Top
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])

      Row(){
        Text(_arrStr[index])
          .textShadow({
            radius: 1,
            type: ShadowType.COLOR,
            color: $r('app.color.main'),
            offsetX: 1,
            offsetY: 1
          })
          .fontColor($r('app.color.reverse'))
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
          .backgroundColor('transparent')

        if(index === 1){
          Row({ space: 10 }){
            Text(_subArrStr[0])
              .fontColor(this.subIndex == 0 ? $r('app.color.app_red') : $r('app.color.reverse_thin'))
              .fontWeight(FontWeight.Bold)
              .fontSize(this.subIndex == 0 ? 23 : 20)
              .backgroundColor('transparent')
              .onClick(() => {
                this.observableTabsController.changeIndex(0)
                this.showToast('歌单-所有')
              })

            Text(_subArrStr[1])
              .fontColor(this.subIndex == 1 ? $r('app.color.app_red') : $r('app.color.reverse_thin'))
              .fontWeight(FontWeight.Bold)
              .fontSize(this.subIndex == 1 ? 23 : 20)
              .backgroundColor('transparent')
              .onClick(() => {
                this.observableTabsController.changeIndex(1)
                this.showToast('歌单-自建')
              })

            Text(_subArrStr[2])
              .fontColor(this.subIndex == 2 ? $r('app.color.app_red') : $r('app.color.reverse_thin'))
              .fontWeight(FontWeight.Bold)
              .fontSize(this.subIndex == 2 ? 23 : 20)
              .backgroundColor('transparent')
              .onClick(() => {
                this.observableTabsController.changeIndex(2)
                this.showToast('歌单-收藏')
              })
          }
          .align(Alignment.BottomStart)
          .margin({ left: 20, bottom: -5 })
          .layoutWeight(1)
        }
        Button({ type: ButtonType.Circle, stateEffect: true }){
          Image($r('app.media.ic_public_search_filled'))
            .width(25)
            .onClick(() => {
              this.pageInfos.clear()
              this.pageInfos.pushPathByName('SearchPage', null, true)
            })
            .fillColor($r('app.color.reverse'))
            .backgroundColor('transparent')
        }
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
        .backgroundColor('transparent')
        .width(40)
        .height(40)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        left: '50px',
        right: '50px',
      })

    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])
    // .backgroundBlurStyle(BlurStyle.Thin)
    .backgroundColor('transparent')
    .opacity(this.getOpacity(index))
  }

  getOpacity(index: number): number{
    if(index != 1){
      return this.titleOpacity[index]
    }
    return this.subTitleOpacity[this.subIndex]
  }

  showToast(msg: string) {
    promptAction.showToast({ message: msg, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.BACKGROUND_THIN })
  }
}

