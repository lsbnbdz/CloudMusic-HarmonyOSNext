import { getPlayLists } from "../../api/playListApi"
import { playList } from "../../common/entities/PlayList"
import { PlayListCard } from "./PlayListCard"
import { SpinKit, SpinType } from '@pura/spinkit'
import { LogUtil } from "@pura/harmony-utils";

@Component
export struct PlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State isLoading:boolean = false
  @State isLoadingMore:boolean = false
  @State hasMore:boolean = false

  @State playLists:Array<playList> = new Array()
  private currentOffset:number = 0

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
          ForEach(this.playLists, (item: playList, index) => {
            ListItem() {
              PlayListCard({playList: item})
            }
          })
          // 添加加载更多
          if (this.isLoadingMore) {
            ListItem() {
              Column() {
                SpinKit({ spinType: SpinType.spinO, spinSize: 30, spinColor: Color.Gray }).width(30)
              }.justifyContent(FlexAlign.Center).width('100%').height(50)
            }
          } else if (this.hasMore) {
            ListItem() {
              Text("点击加载更多")
                .onClick(async () => {
                  this.isLoadingMore = true
                  let moreResult = await getPlayLists(this.currentOffset + 20)
                  this.playLists = [...this.playLists,...moreResult.playlist]
                  setTimeout(() => {
                    this.isLoadingMore = false
                  },0)
                })
                .padding({ top:10 })
                .fontColor($r('app.color.reverse'))
                .width('100%')
                .textAlign(TextAlign.Center)
            }
          } else if (!this.hasMore) {
            ListItem() {
              Text('没有更多了~').fontSize(16).textAlign(TextAlign.Center).width('100%').height(50);
            }
          }
          ListItem().height(px2vp(this.bottomRectHeight))
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