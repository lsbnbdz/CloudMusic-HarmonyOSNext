import { EmitterUtil, LogUtil } from "@pura/harmony-utils"
import { SpinKit, SpinType } from "@pura/spinkit"
import { searchPlayLists } from "../../api/playListApi"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { PlayList } from "../../common/entities/PlayList"
import { PlayListCard } from "../cards/PlayListCard"

const TAG = "[SearchPlayListsList] "
@Component
export struct SearchPlayListsList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('set-hasAnimation') hasAnimation: boolean = true
  @State playLists: Array<PlayList> = []
  @Prop searchKeyword: string = ''
  @State playListOffset: number = 0
  @State hasMorePlayLists: boolean = true
  @State hasPlayListLoaded: boolean = false
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.loadPlayLists(0)
    }
    EmitterUtil.onSubscribe(EmitterConstants.EMITTER_SEARCH, async (keyword: string) => {
      this.searchKeyword = keyword
      this.playLists = []
      this.playListOffset = 0
      await this.loadPlayLists(0)
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(EmitterConstants.EMITTER_SEARCH)
  }

  build() {
    if(this.isLoading == true) {
      Column() {
        SpinKit({ spinType: SpinType.spinO, spinSize:60, spinColor:Color.Gray }).width(60)
      }
      .padding({ bottom: px2vp(this.topRectHeight) })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.playLists, (item: PlayList, index) => {
          ListItem() {
            PlayListCard({ playList: item, hasAnimation: this.hasAnimation })
          }
        })
        if (this.isLoadingMore) {
          ListItem() {
            Column() {
              SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
            }.justifyContent(FlexAlign.Center).width('100%').height(50)
          }
        } else if (this.hasMorePlayLists && this.searchKeyword) {
          ListItem() {
            Text("点击加载更多")
              .onClick(() => {
                this.loadPlayLists(this.playListOffset)
              })
              .padding({ top: 10, bottom: px2vp(this.bottomRectHeight) })
              .fontColor($r('app.color.reverse'))
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        } else if (!this.hasMorePlayLists) {
          ListItem() {
            Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
          }
        }
        ListItem().height(px2vp(this.bottomRectHeight) + 80)
      }
      .layoutWeight(1)
      .width('100%')
      .scrollBar(BarState.On)
      .height('100%')
    }
  }

  async loadPlayLists(offset: number): Promise<void> {
    if(!this.hasMorePlayLists) return
    if(offset == 0) { this.isLoading = true }
    else { this.isLoadingMore = true }
    try {
      const result = await searchPlayLists(this.searchKeyword, offset)
      this.playLists = [...this.playLists, ...result.playlist]
      this.playListOffset += 15
      this.hasMorePlayLists = result.more
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching playLists: ', JSON.stringify(e));
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasPlayListLoaded = true
    }
  }
}