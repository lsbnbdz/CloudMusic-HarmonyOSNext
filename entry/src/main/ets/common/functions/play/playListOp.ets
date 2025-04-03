import { LogUtil } from "@pura/harmony-utils"
import { putPlayListInQueue } from "../../../api/playListApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { PlayingPlayList } from "../../entities/playlist/PlayList"
import { playQueue } from "./playControl"

const TAG = '[playListOp] '
export async function playListToQueue(id: number, count: number, currentIndex: number = 0) {
  try {
    AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, true)
    const lastPlayInfo = await AppStorage.get(StorageConstants.LAST_PLAYED_LIST) as PlayingPlayList
    if(lastPlayInfo.id != -1 && lastPlayInfo.id == id && lastPlayInfo.count == count) {
      playQueue(currentIndex)
    } else {
      let limit = currentIndex > 100 ? currentIndex + 5 : 100
      await putPlayListInQueue(id, limit, limit, 0)
      playQueue(currentIndex)
      await putPlayListInQueue(id, count, 1000, limit, false)
    }
  } catch (e) {
    LogUtil.error(TAG + '播放歌单失败: ' + e.message)
  } finally {
    const playInfo: PlayingPlayList = {
      id: id,
      count: count
    }
    AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
    AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, false)
  }
}

export function cleanLastPlayInfo() {
  const playInfo: PlayingPlayList = {
    id: -1,
    count: -1
  }
  AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
}