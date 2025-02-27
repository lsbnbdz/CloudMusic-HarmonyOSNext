import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getLikeList, likeMusic } from "../../../api/songApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { Song } from "../../entities/SongsResult"
import { User } from "../../entities/User"

const TAG = '[songLike] '
/**
 * 判断当前歌曲是否被喜欢
 * @param sid
 */
export async function isThisSongLiked(sid: number) {
  let isLiked: boolean = false
  try {
    let likelist: string[] = await AppStorage.get(StorageConstants.USER_LIKELIST) as string[]
    if(likelist.length != 0) {
      isLiked = likelist.map(Number).includes(sid)
    }
  } catch (e) {
    LogUtil.error(TAG + 'isThisSongLiked Error: ' + e.message)
  } finally {
    AppStorage.setOrCreate(StorageConstants.ISLIKED, isLiked)
  }
}

/**
 * 喜欢当前歌曲
 */
export async function likeThisSong() {
  try {
    let isLogged: boolean = AppStorage.get(StorageConstants.IS_LOGGED) as boolean
    if (await AppStorage.get(StorageConstants.ISLIKED) as boolean || !isLogged) {
      return
    } else {
      let currentSong = await AppStorage.get(StorageConstants.PLAY_SONG) as Song
      let result = await likeMusic(currentSong.id)
      AppStorage.setOrCreate(StorageConstants.ISLIKED, result)
      getLikeList()
      ToastUtil.showToast(result ? '收藏成功' : '收藏失败')
    }
  } catch (e) {
    LogUtil.error(TAG + '喜欢当前歌曲时出错: ' + e.message)
  }
}