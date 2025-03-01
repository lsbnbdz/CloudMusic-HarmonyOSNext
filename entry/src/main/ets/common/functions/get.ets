import { StorageConstants } from "../constants/StorageConstants";

export async function getCookie(): Promise<string> {
  let cookie = ''
  let isCustomCookie = await AppStorage.get(StorageConstants.IS_CUSTOM_COOKIE) as boolean
  if(isCustomCookie) {
    cookie = await AppStorage.get(StorageConstants.CUSTOM_COOKIE) as string
  } else {
    cookie = await AppStorage.get(StorageConstants.COOKIE) as string
  }
  return cookie
}