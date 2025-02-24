import { Explore } from '../components/main/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import { router } from '@kit.ArkUI';
import { RecommendCards_NotLogged } from '../components/cards/RecommendCards';
import Constants from '../common/constants/Constants';
import { SettingsPage } from './SettingsPage';
import { DownloadPage } from './DownloadPage';
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
import { FullPlayerPage } from './FullPlayerPage';

@Entry
@Component
struct Index {
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State index: number = 0
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  private menuItems: NavigationMenuItem[] = [
    {
      value: '搜索',
      icon: $r('app.media.ic_public_search_filled'),
      action: () => {
        this.pageInfos.pushPathByName('SearchPage', null)
      }
    }
  ]

  async build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.index == 0) {
          Explore()
        } else if(this.index == 1) {
          UserPlayLists()
        } else if(this.index == 2) {
          Me()
        }

        BottomBarComponent()
          .padding(Constants.PADDING_EDGE_DEFAULT)
          .backgroundColor(Color.Transparent)
      }
    }
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .title(this.index == 0 ? '发现' : this.index == 1 ? '歌单' : '我的')
    .menus(this.menuItems)
    .hideBackButton(true)
    .backgroundColor($r('app.color.background'))
    .navDestination(this.PageMap)
    .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular })
  }

  @Builder PageMap(name: string, param: Object) {
    if(name === 'SettingsPage') {
      SettingsPage()
    }
    // else if(name === 'FullPlayerPage') {
    //   FullPlayerPage()
    // }
    else if(name === 'DownloadPage') {
      DownloadPage()
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
  }

  @Builder
  NotLogged() {
    List({ space: 10 }) {
      ListItem() {
        Search({
          placeholder: '搜索内容',
          icon: '/resources/base/media/ic_public_search_filled.svg',
        })
          .sharedTransition('search_component', {
            duration: 300,
            curve: Curve.Friction
          })
          .focusable(false)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/SearchPage'
            })
          })
      }
      .padding({ left: 20, right: 20 })
      ListItem() {
        RecommendCards_NotLogged()
      }
      ListItem() {
        Column({ space: 15 }) {
          Text('尚未登录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .padding({ top: 100 })
          Text('点击左上角图标进行登录\n以获取日推、歌单、云盘等内容')
            .fontSize(18)
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .layoutWeight(1)
      }
    }
    .scrollBar(BarState.Off)
    .height('100%')
    .width('100%')
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
      this.index = index
    })
  }
}