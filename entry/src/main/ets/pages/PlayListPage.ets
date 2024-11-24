import { router } from '@kit.ArkUI';
import { Song } from '../common/entities/SongsResult';
import { SongCard } from '../components/main/SongCard';
import { playList } from '../common/entities/PlayList';
import { PlayListHead } from '../components/head/PlayListHead';
import { getPlayListSongs } from '../api/getPlayListSongs';

/**
 * 歌单二级页面
 */

@Entry
@Component
struct PlayListPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  private playList:playList = Object(router.getParams())['playList']

  @State hasLoaded:boolean = false // 判定是否已加载 避免重复加载
  @State isLoading:boolean = true
  @State list:Array<Song> = new Array()

  async onPageShow(): Promise<void> {
    if (!this.hasLoaded) {
      await this.loadSongs();
    }
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true;
    try {
      const result = await getPlayListSongs(this.playList.id);
      this.list = result;
      this.isLoading = false;
      this.hasLoaded = true;
    } catch (e) {
      console.error('Error fetching songs: ', e);
    }
  }

  build() {
    Column() {
      if(this.isLoading == true) {
        Column() {
          LoadingProgress().width(80)
        }.height('100%').width('100%').justifyContent(FlexAlign.Center)
      } else {
        PlayListHead({ playListName: this.playList.name })
        List() {
          ForEach(this.list, (item: Song, index) => {
            ListItem() {
              SongCard({ song: item, sid: index })
            }
          })
        }.height(`calc(100% - 70px - ${this.topRectHeight}px - ${this.bottomRectHeight}px)`).width('100%').scrollBar(BarState.Auto)
      }
    }
    .backgroundColor($r('app.color.main'))
  }
}