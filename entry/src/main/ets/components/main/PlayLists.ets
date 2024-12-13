import { getPlayLists } from "../../api/playListApi"
import { playList } from "../../common/entities/PlayList"
import { PlayListCard } from "./PlayListCard"
import { SpinKit, SpinType } from '@pura/spinkit'
import { LogUtil } from "@pura/harmony-utils";
import { SearchComponent } from "./SearchComponent";

@Component
export struct PlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State isLoading:boolean = false
  @State isLoadingMore:boolean = false
  @State hasMore:boolean = false

  @State playLists:Array<playList> = new Array()

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      const result = await getPlayLists(0)
      this.playLists = result.playlist
      LogUtil.info('Get play lists: ' + JSON.stringify(this.playLists))
      this.hasMore = result.more
      setTimeout(() => {
        this.isLoading = false
      }, 100)
    } catch (e) {
      LogUtil.error('Error fetching playlists: ', e)
    }
  }

  @Builder
  itemLayout(playList: playList, index: number): void {
    PlayListCard({playList: playList})
  }

  build() {
    Column() {
      if(this.isLoading == true) {
        Column() {
          SpinKit({ spinType: SpinType.spinG, spinSize:60, spinColor:Color.Gray })
            .width(60)
        }
        .height('100%')
        .padding({ bottom: px2vp(this.topRectHeight) })
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      else {
        List({ space: 10 }) {

          SearchComponent()
            .padding({ left: 20, right: 20 })

          ForEach(this.playLists, (item: playList, index) => {
            ListItem() {
              PlayListCard({playList: item})
            }
          })
          ListItem().height( px2vp(this.bottomRectHeight) + 120 )
        }
        .height('100%')
        .width('100%')
        .borderRadius(20)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
  }

}