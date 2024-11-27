import { getPlayLists } from "../../api/getPlayLists"
import { playList } from "../../common/entities/PlayList"
import { PlayListCard } from "./PlayListCard"
import { SpinKit, SpinType } from '@pura/spinkit'

@Component
export struct PlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  @State isLoading:boolean = false
  @State playLists:Array<playList> = new Array()

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      const result = await getPlayLists()
      this.playLists = result

      setTimeout(() => {
        this.isLoading = false
      }, 0)
    } catch (e) {
      console.error('Error fetching playlists: ', e)
    }
  }

  build() {
    Column() {
      if(this.isLoading == true) {
        Column() {
          SpinKit({ spinType: SpinType.spinG, spinSize:60, spinColor:Color.Gray }).width(60)
        }.height('50%').width('100%').justifyContent(FlexAlign.Center)
      }
      else {
        List() {
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