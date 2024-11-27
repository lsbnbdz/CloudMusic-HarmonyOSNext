import { SongsListHead } from '../components/head/SongsListHead';
import { router } from '@kit.ArkUI';
import { getSongsList } from '../api/getSongsList';
import { Song } from '../common/entities/SongsResult';
import { SongCard } from '../components/main/SongCard';

/**
 * 歌曲列表页（搜索结果）
 */

@Entry
@Component
struct SongsListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State hasLoaded:boolean = false // 判定是否已加载 避免重复加载
  @State isLoading:boolean = true
  @State list:Array<Song> = new Array()
  private searchKeyword:string = Object(router.getParams())['searchKeyword']

  async onPageShow(): Promise<void> {
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
      console.error('Error fetching songs: ', e);
    }
  }

  build() {
    Stack() {
      if(this.isLoading == true) {
        Column() {
          LoadingProgress().width(80)
        }.height('100%').width('100%').justifyContent(FlexAlign.Center)
      } else {
        Column() {
          SongsListHead({ searchKeyword: this.searchKeyword })
          List() {
            ForEach(this.list, (item: Song, index) => {
              ListItem() {
                SongCard({ song: item, sid: index })
              }
            })
            ListItem().padding({bottom: px2vp(this.bottomRectHeight)})
          }.layoutWeight(1).width('100%').scrollBar(BarState.Auto)
        }
        .height('100%')
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })
    .backgroundColor($r('app.color.main'))
  }
}