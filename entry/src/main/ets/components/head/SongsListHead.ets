import { BackButton } from "../buttons/BackButton";

/**
 * 歌曲列表Head
 */

@Component
export struct SongsListHead {
  searchKeyword:string = '';

  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    Row({ space: 20 }) {
      BackButton()
      Text(`"${this.searchKeyword}" 的搜索结果`).fontSize(20).fontColor($r('app.color.reverse')).width('80%').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

    }
    // 避让状态栏
    .padding({ left: 15, right: 10 })
    .width('100%')
    .backgroundColor(Color.Transparent)
  }
}