import { getPlayLists } from "../../api/getPlayLists"
import { playList } from "../../common/entities/PlayList"
import { PlayListCard } from "./PlayListCard"

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
          LoadingProgress().width(80)
        }.height('50%').width('100%').justifyContent(FlexAlign.Center)
      }
      else {
        List() {
          ForEach(this.playLists, (item: playList, index) => {
            ListItem() {
              PlayListCard({playList: item})
            }
          })
        }.height(`calc(100% - ${vp2px(this.topRectHeight) + 80}px)`).width('100%').scrollBar(BarState.Auto)
      }
    }.width('100%').height('100%')
  }
}