import { ToastUtil } from "@pura/harmony-utils"
import { getLikeList, likeMusic } from "../../../api/songApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { Song } from "../../entities/SongsResult"
import { User } from "../../entities/User"

/**
 * 判断当前歌曲是否被喜欢
 * @param sid
 */
export async function isThisSongLiked(sid: number) {
  let likelist: string[] = await AppStorage.get(StorageConstants.USER_LIKELIST) as string[]
  if(likelist.length == 0) {
    let user = AppStorage.get(StorageConstants.USER) as User
    likelist = await getLikeList(user.data.profile.userId)
  }
  const isLiked = likelist.map(Number).includes(sid)
  AppStorage.setOrCreate(StorageConstants.ISLIKED, isLiked)
}

/**
 * 喜欢当前歌曲
 */
export async function likeThisSong() {
  if(await AppStorage.get(StorageConstants.ISLIKED) as boolean) { return }
  else {
    let currentSong = await AppStorage.get(StorageConstants.PLAY_SONG) as Song
    AppStorage.setOrCreate(StorageConstants.ISLIKED, true)
    ToastUtil.showToast(await likeMusic(currentSong.id) ? '收藏成功' : '收藏失败')
  }
}