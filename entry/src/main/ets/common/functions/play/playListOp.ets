import { LogUtil } from "@pura/harmony-utils"
import { putPlayListInQueue } from "../../../api/playListApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { playQueue } from "./playControl"

const TAG = '[playListOp] '
export async function playListToQueue(id: number, count: number, currentIndex: number = 0) {
  try {
    AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, true)
    let limit = 100
    if (currentIndex > 100) {
      limit = currentIndex
    }
    await putPlayListInQueue(id, limit, 100, 0)
    playQueue(currentIndex)
    await putPlayListInQueue(id, count, 500, limit, false)
  } catch (e) {
    LogUtil.error(TAG + '播放歌单失败: ' + e.message)
  } finally {
    AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, false)
  }
}