import { putPlayListInQueue } from "../../api/playListApi"
import { playQueue } from "./playerControl"

export async function playListToQueue(id: number, count: number, currentIndex: number = 0) {
  AppStorage.setOrCreate('isPlayerLoading', true)
  let limit = 100
  if(currentIndex > 100) {
    limit = currentIndex
  }
  await putPlayListInQueue(id, limit, 100, 0)
  playQueue(currentIndex)
  await putPlayListInQueue(id, count - limit, 500, limit, false)
  AppStorage.setOrCreate('isPlayerLoading', false)
}