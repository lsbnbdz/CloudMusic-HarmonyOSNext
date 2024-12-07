import { avSession } from "@kit.AVSessionKit";
import { AppUtil } from "@pura/harmony-utils";
import { BusinessError } from "@kit.BasicServicesKit";
import { Song } from "../entities/SongsResult";
import { pauseMusic, playNext, playPre, resumeMusic } from "../functions/playerControl";

export async function createSession(): Promise<avSession.AVSession> {

  let mode: number | undefined = AppStorage.get('player-mode')
  let song: Song | undefined = AppStorage.get('player-song')
  let artists: string | undefined = AppStorage.get('player-artists')
  let picUrl: string | undefined = AppStorage.get('player-picurl')

  const context = AppUtil.getContext()
  const session = await avSession.createAVSession(context, 'playSession', 'audio')

  // 设置必要的媒体信息
  let metadata: avSession.AVMetadata = {
    assetId: '0',
    title: song?.name,
    mediaImage: picUrl,
    artist: artists,
    duration: song?.duration
  }
  session.setAVMetadata(metadata).then(() => {
    console.info(`SetAVMetadata successfully`);
  }).catch((err: BusinessError) => {
    console.error(`Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
  })

  // 设置状态： 播放状态，进度位置，播放倍速，缓存的时间
  let playbackState: avSession.AVPlaybackState = {
    state: avSession.PlaybackState.PLAYBACK_STATE_BUFFERING, // 确保播放状态为播放
    position: {
      elapsedTime: 0, // 已经播放的位置，以ms为单位，后面可以根据实际播放进度更新
      updateTime: new Date().getTime(),
    }
  }

  session.setAVPlaybackState(playbackState, (err) => {
    if (err) {
      console.error(`Failed to set AVPlaybackState. Code: ${err.code}, message: ${err.message}`);
    } else {
      console.info(`SetAVPlaybackState successfully`);
    }
  })

  session.on('play', () => {
    resumeMusic()
  })

  session.on('pause', () => {
    pauseMusic()
  })

  session.on('playNext', () => {
    playNext()
  })

  session.on('playPrevious', () => {
    playPre()
  })

  return session
}

async function getPlayTime() {
  let resTime = 0
  let elapsedTime:number | undefined = await AppStorage.get('player-time')
  if(elapsedTime) {
    resTime = elapsedTime
  }
  return resTime
}

export async function sessionPause(session: avSession.AVSession) {
  let time = await getPlayTime()
  let pausedState: avSession.AVPlaybackState = {
    state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE, // 确保播放状态为播放
    position: {
      elapsedTime: time,
      updateTime: new Date().getTime()
    }
  }
  session.setAVPlaybackState(pausedState)
}

export async function sessionPlay(session: avSession.AVSession) {
  let time = await getPlayTime()
  let playbackState: avSession.AVPlaybackState = {
    state: avSession.PlaybackState.PLAYBACK_STATE_PLAY, // 确保播放状态为播放
    position: {
      elapsedTime: time,
      updateTime: new Date().getTime()
    }
  }
  session.setAVPlaybackState(playbackState)
}