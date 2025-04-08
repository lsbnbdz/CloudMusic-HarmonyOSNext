import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { putPlayListInQueue } from "../../../api/playListApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { PlayQueue } from "../../entities/local/PlayQueue"
import { PlayingPlayList } from "../../entities/playlist/PlayList"
import { PlayListSong } from "../../entities/playlist/PlayListSongs"
import PlayQueueUtils from "../../utils/play/PlayQueueUtils"
import { playQueue } from "./playControl"

const TAG = '[playListOp] '
// export async function playListToQueue(id: number, count: number, currentIndex: number = 0) {
//   try {
//     AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, true)
//     const lastPlayInfo = await AppStorage.get(StorageConstants.LAST_PLAYED_LIST) as PlayingPlayList
//     if(lastPlayInfo.id != -1 && lastPlayInfo.id == id && lastPlayInfo.count == count) {
//       playQueue(currentIndex)
//     } else {
//       let limit = currentIndex > 100 ? currentIndex + 5 : 100
//       await putPlayListInQueue(id, limit, limit, 0)
//       playQueue(currentIndex)
//       await putPlayListInQueue(id, count, 1000, limit, false)
//     }
//   } catch (e) {
//     LogUtil.error(TAG + '播放歌单失败: ' + e.message)
//   } finally {
//     const playInfo: PlayingPlayList = {
//       id: id,
//       count: count
//     }
//     AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
//     AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, false)
//   }
// }

export async function playListToQueue(playlist: PlayListSong[], index: number) {
  try {
    if(playlist.length === 0) return
    let queue: PlayQueue[] = playlist.map((item): PlayQueue => ({
      playmode: 2,
      song: {
        id: item.id,
        name: item.name,
        artists: item.ar,
        album: item.al,
        duration: item.dt,
        fee: item.fee,
        alias: []
      },
      fileName: '',
      picUrl: item.al.picUrl
    }))
    await PlayQueueUtils.cleanQueue()
    await PlayQueueUtils.queueAdd_array(queue)
    playQueue(index)
  } catch (e) {
    ToastUtil.showToast('播放失败: ' + e.message)
    LogUtil.error(TAG + 'playlist to queue error: ' + e.stack)
  }
}

export function cleanLastPlayInfo() {
  const playInfo: PlayingPlayList = {
    id: -1,
    count: -1
  }
  AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
}