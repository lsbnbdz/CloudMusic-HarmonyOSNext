import { LazyData } from "@pie/lazy-data"
import { getDjPrograms } from "../../api/djApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { DjRadioProgram } from "../../common/entities/dj/DjProgramResult"
import { djRadioItem } from "../../common/entities/dj/DjResult"
import { DjRadioParam } from "../../common/entities/local/PageParams"
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from "../../components/buttons/LoadMoreButtons"
import { SongCard } from "../../components/cards/SongCard"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"

@Component
export struct DjRadioPage {
  param: DjRadioParam = { djRadio: djRadioItem }
  @StorageProp(StorageConstants.BREAKPOINT) breakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @State programs: DjRadioProgram[] = []
  @State dataSource: LazyData<DjRadioProgram> = new LazyData()
  @State songsOffset: number = 0
  @State translateY: number = 40
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State hasMore: boolean = false
  @Provide('playmode') playmode: number = 3

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    await this.loadSongs(0)
    this.isLoading = false
  }

  async loadSongs(offset: number) {
    let result = await getDjPrograms(this.param.djRadio.id, 30, offset)
    this.songsOffset += 30
    this.hasMore = result.more
    this.programs = [...this.programs, ...result.programs]
    this.dataSource.setData(this.programs)
    this.dataSource.notifyDataReload()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress()
              .width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        else {
          List() {
            ListItem()
              .height(px2vp(this.topRectHeight) + Constants.PADDING_EDGE_TEXT)
            LazyForEach(this.dataSource, (item: DjRadioProgram, index) => {
              SongCard({
                song: item.mainSong,
                picUrl: item.coverUrl,
                playmode: 3
              })
                .translate({ y: this.translateY })
                .animation({
                  duration: 600,
                  curve: Curve.LinearOutSlowIn
                })
                .onAppear(() => { this.translateY = 0 })
                .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
            })

            if(this.hasMore) {
              if(this.isLoadingMore) {
                LoadingMoreButton()
              } else {
                ClickToLoadButton()
                  .onClick(async() => {
                    this.isLoadingMore = true
                    await this.loadSongs(this.songsOffset)
                    this.isLoadingMore = false
                  })
              }
            } else {
              NoMoreButton()
            }

            ListItem()
              .height(Constants.HEIGHT_MINI + px2vp(this.bottomRectHeight))
          }
          .width('100%')
          .height('100%')
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }

        if(this.breakpoint !== 'lg') {
          BottomBarComponent()
            .padding(Constants.PADDING_EDGE_DEFAULT)
            .backgroundColor(Color.Transparent)
        }
      }
    }
    .title(this.param.djRadio.name, { barStyle: BarStyle.STACK, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.Regular })
    .backgroundColor($r('app.color.background'))
  }
}