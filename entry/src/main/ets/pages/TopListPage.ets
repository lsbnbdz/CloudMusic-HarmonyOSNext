import Constants from "../common/constants/Constants"
import { StorageConstants } from "../common/constants/StorageConstants"
import { TopListItem } from "../common/entities/TopList"
import { TopListItemCard } from "../components/cards/TopListItemCard"

@Component
export struct TopListPage {
  @StorageLink(StorageConstants.TOPLISTS) topList: Array<TopListItem> = []

  build() {
    NavDestination() {
      Grid() {
        GridItem() {
          GridRow({
            columns: {
              xs: 2,
              sm: 3,
              md: 2,
              lg: 3,
              xl: 3
            }
          }) {
            ForEach(this.topList, (item: TopListItem) => {
              GridCol() {
                TopListItemCard({ topListItem: item }).padding(Constants.PADDING_EDGE_DEFAULT)
              }
            })
          }
        }
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .height('100%')
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.On)
      .rowsGap(15)
      .columnsTemplate('1fr')
      .layoutDirection(GridDirection.Column)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title('排行榜')
    .backgroundColor($r('app.color.background'))
  }
}