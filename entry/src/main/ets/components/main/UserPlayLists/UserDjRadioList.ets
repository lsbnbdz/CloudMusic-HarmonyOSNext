import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import { getDjSublist } from "../../../api/djApi";
import { StorageConstants } from "../../../common/constants/StorageConstants";
import { DjRadio } from "../../../common/entities/dj/DjResult";
import { DjRadioParam } from "../../../common/entities/local/PageParams";
import { DjRadioCard } from "../../cards/DjRadioCard";
import { PlayListCard_Skeleton } from "../../cards/PlayListCard";

@Component
export struct UserDjRadioList {
  @StorageProp(StorageConstants.USER_DJRADIO_LIST) djRadioList: DjRadio[] = []
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getRadioList') isLogged: boolean = false
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    try {
      await this.getRadioList()
    } catch (e) {
      LogUtil.error('获取歌单列表失败')
    } finally {
      this.isLoading = false
    }
  }

  private async getRadioList() {
    if(this.isLogged && this.djRadioList.length == 0) {
      this.isLoading = true
      const result = await getDjSublist()
      this.djRadioList = result.djRadios
      this.isLoading = false
    }
    else return
  }

  private async refreshContent() {
    if (!this.isLogged) return
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        const result = await getDjSublist()
        this.djRadioList = []
        this.djRadioList = result.djRadios
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
      }
    }
    this.isRefreshing = false
  }

  build() {
    Refresh({ refreshing: this.isRefreshing}) {
      if(this.isLoading) {
        this.Loading()
      }
      List() {
        ForEach(this.djRadioList, (item: DjRadio, index) => {
          DjRadioCard({ djRadio: item })
            .onClick(() => {
              const param: DjRadioParam = {
                djRadio: item
              }
              this.pageInfos.pushPathByName('DjRadioPage', param)
            })
        })
      }
      .width('100%')
      .height('100%')
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onRefreshing(async () => {
      await this.refreshContent()
    })
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListCard_Skeleton()
    })
  }
}