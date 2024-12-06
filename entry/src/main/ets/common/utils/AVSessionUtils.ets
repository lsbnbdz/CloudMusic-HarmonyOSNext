import { avSession } from "@kit.AVSessionKit";
import { AppUtil } from "@pura/harmony-utils";
import { BusinessError } from "@kit.BasicServicesKit";

export async function createSession(): Promise<avSession.AVSession> {
  const context = AppUtil.getContext()
  const session = await avSession.createAVSession(context, 'playSession', 'audio')

  // 设置必要的媒体信息
  let metadata: avSession.AVMetadata = {
    assetId: '0', // 由应用指定，用于标识应用媒体库里的媒体
    title: 'TITLE',
    mediaImage: 'IMAGE',
    artist: 'ARTIST',
    duration: 0
  };
  session.setAVMetadata(metadata).then(() => {
    console.info(`SetAVMetadata successfully`);
  }).catch((err: BusinessError) => {
    console.error(`Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
  });

  return session
}