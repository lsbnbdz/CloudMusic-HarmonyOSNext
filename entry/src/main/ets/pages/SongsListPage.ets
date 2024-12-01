import { router } from '@kit.ArkUI';
import { getSongsList } from '../api/getSongsList';
import { Song } from '../common/entities/SongsResult';
import { SongCard } from '../components/main/SongCard';
import { ListHead } from '../components/head/ListHead';
import { LogUtil } from '@pura/harmony-utils';
import { SpinKit, SpinType } from '@pura/spinkit';

/**
 * 歌曲列表页（搜索结果）
 */
const TAG = "[SongListPage] "
@Entry
@Component
struct SongsListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State hasLoaded:boolean = false // 判定是否已加载 避免重复加载
  @State isLoading:boolean = true
  @State list:Array<Song> = new Array()
  private searchKeyword:string = Object(router.getParams())['searchKeyword']
  hasAnimation:boolean | undefined = false

  async onPageShow(): Promise<void> {
    this.hasAnimation = AppStorage.get('set-hasAnimation')
    if (!this.hasLoaded) {
      await this.loadSongs();
    }
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await getSongsList(this.searchKeyword);
      this.list = result;
      this.isLoading = false;
      this.hasLoaded = true;
    } catch (e) {
      LogUtil.error( TAG + 'Error fetching songs: ', JSON.stringify(e));
    }
  }

  build() {
    Stack() {
      if(this.isLoading == true) {
        Column() {
          SpinKit({ spinType: SpinType.spinF, spinSize:60, spinColor:Color.Gray }).width(60)
        }
        .height('100%')
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      else {
        Column() {
          ListHead({ title: `"${this.searchKeyword}" 的搜索结果` })
          List() {
            ForEach(this.list, (item: Song, index) => {
              ListItem() {
                SongCard({ song: item, sid: index, hasAnimation: this.hasAnimation })
              }
            })
            ListItem().padding({ bottom: px2vp(this.bottomRectHeight) })
          }
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Auto)
          .height('100%')
        }
        .height('100%')
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.main'))
  }
}