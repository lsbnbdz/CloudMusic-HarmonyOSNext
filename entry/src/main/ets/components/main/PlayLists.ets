import { getPlayLists } from "../../api/getPlayLists"
import { playList } from "../../common/entities/PlayList"
import { PlayListCard } from "./PlayListCard"
import { SpinKit, SpinType } from '@pura/spinkit'
import { LogUtil } from "@pura/harmony-utils";
import { RefreshController } from '@abner/refresh'

@Component
export struct PlayLists {
  controller: RefreshController = new RefreshController() //刷新控制器
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State isLoading:boolean = false
  @State playLists:Array<playList> = new Array()

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      const result = await getPlayLists(true)
      this.playLists = result

      setTimeout(() => {
        this.isLoading = false
      }, 0)
    } catch (e) {
      LogUtil.error('Error fetching playlists: ', e)
    }
  }


  @Builder
  itemLayout(_: playList, index: number): void {
    PlayListCard({playList: _})
  }

  build() {
    Column() {
      if(this.isLoading == true) {
        Column() {
          SpinKit({ spinType: SpinType.spinG, spinSize:60, spinColor:Color.Gray }).width(60)
        }.height('50%').width('100%').justifyContent(FlexAlign.Center)
      }
      else {
        // ListView({
        //   controller: this.controller,
        //   items: this.playLists,
        //   itemLayout: (item: Object, index: number) => {
        //     this.itemLayout(item as playList, index)
        //   },
        //   isScrollSpring: true,
        //   onRefresh: async () => {
        //     this.playLists = []
        //     this.isLoading = true
        //     try {
        //       const result = await getPlayLists(false)
        //       this.playLists = result
        //
        //       setTimeout(() => {
        //         this.isLoading = false
        //       }, 0)
        //     } catch (e) {
        //       LogUtil.error('Error fetching playlists: ', e)
        //     }
        //   }
        // })

        List({ space: 10 }) {
          ForEach(this.playLists, (item: playList, index) => {
            ListItem() {
              PlayListCard({playList: item})
            }
          })
          ListItem().height(px2vp(this.bottomRectHeight))
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Auto)
      }
    }.width('100%').height('100%')
  }
}