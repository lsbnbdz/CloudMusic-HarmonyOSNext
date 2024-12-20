import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getPlayLists, PlayListOperation } from "../../api/playListApi"
import { playList } from "../../common/entities/PlayList"
import { Song } from "../../common/entities/SongsResult"
import { PlayQueueButton } from "../buttons/PlayQueueButton"
import { PlayListCard } from "../main/PlayListCard"

/**
 * 添加至歌单Sheet
 */
const TAG = '[PlayListAddSheet] '

@Component
export struct PlayListAddSheet {
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isLoading: boolean = false
  @State playLists: Array<playList> = new Array()
  @State songId: number = -1
  @Link isShow: boolean

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      const result = await getPlayLists(0)
      this.playLists = result.playlist
      setTimeout(() => {
        this.isLoading = false
      }, 100)
    } catch (e) {
      LogUtil.error(TAG + 'Error fetching playlists: ', e)
    }
  }

  build() {
    Column({ space: 10 }) {
      Text('添加到歌单')
      if(this.isLoading) {
        Column() {
          LoadingProgress().width(40)
        }
        .width('100%')
      }
      else {
        List() {
          ForEach(this.playLists, (item: playList, index) => {
            ListItem() {
              Button() {
                Row({ space:15 }) {
                  Image(`${item.coverImgUrl}?param=128y128`).width(50).borderRadius(15)
                  Column({ space: 8 }) {
                    Text(item.name).textStyle(16).fontWeight(FontWeight.Medium)
                    Text(`${item.trackCount} 首歌曲`).textStyle(12)
                  }
                  .layoutWeight(1)
                }
                .width('100%')
              }
              .backgroundColor(Color.Transparent)
              .borderRadius(5)
              .type(ButtonType.Normal)
              .width('100%')
              .height(60)
              .padding({ left: 20, right: 20 })
              .onClick(async () => {
                LogUtil.info(TAG + 'songId: ' + this.songId)
                try {
                  await PlayListOperation('add', item.id, this.songId)
                  ToastUtil.showToast('成功添加到歌单')
                  this.isShow = false
                } catch (e) {
                  LogUtil.info(TAG + 'Add to PlayList Error: ' + JSON.stringify(e))
                  ToastUtil.showToast('添加到歌单失败')
                }
              })
            }
          })
          ListItem().height(px2vp(this.bottomRectHeight))
        }
        .layoutWeight(1)
        .width('100%')
      }
    }
    .padding({ left:20, right:20, top:15 })
    .width('100%')
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}