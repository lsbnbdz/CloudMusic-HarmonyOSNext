import { avSession } from "@kit.AVSessionKit";
import { AppUtil, LogUtil } from "@pura/harmony-utils";
import { Song } from "../entities/SongsResult";
import { pauseMusic, playNext, playPre, resumeMusic } from "../functions/playerControl";

/**
 * AVSession 播控中心工具类
 */
const TAG = '[AVSessionUtils] '

class AVSessionUtils {
  context = AppUtil.getContext()
  session = this.createSession()

  async createSession(): Promise<avSession.AVSession> {
    let session = await avSession.createAVSession(this.context, 'playSession', 'audio')
    try {
      session.on('play', () => {
        LogUtil.info(TAG + '播控中心点击事件: Play')
        resumeMusic()
      });
      session.on('pause', () => {
        LogUtil.info(TAG + '播控中心点击事件: Pause')
        pauseMusic()
      });
      session.on('playNext', () => {
        LogUtil.info(TAG + '播控中心点击事件: PlayNext')
        playNext()
      });
      session.on('playPrevious', () => {
        LogUtil.info(TAG + '播控中心点击事件: PlayPrevious')
        playPre()
      });
    } catch (e) {
      LogUtil.error(TAG + '创建session失败 / create session error: ' + JSON.stringify(e))
    } finally {
      return session
    }
  }

  /**
   * 设置媒体信息
   * @param song
   * @param artists
   * @param picUrl
   */
  async setMetadata(song: Song, artists: string, picUrl: string) {
    let metadata: avSession.AVMetadata = {
      assetId: '0',
      title: song?.name,
      mediaImage: picUrl,
      artist: artists,
      duration: song?.duration
    };

    (await this.session).setAVMetadata(metadata);
  }

  /**
   * 启用
   */
  async activate() {
    (await this.session).activate()
  }

  /**
   * 停用
   */
  async deactive() {
    (await this.session).deactivate()
  }

  /**
   * 设置为播放状态
   */
  async playState() {
    let time = await getPlayTime()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };

    (await this.session).setAVPlaybackState(playbackState)
  }

  /**
   * 设置为暂停状态
   */
  async pauseState() {
    let time = await getPlayTime()
    let pausedState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };
    (await this.session).setAVPlaybackState(pausedState)
  }

  /**
   * 设置为缓冲状态
   */
  async bufferingState() {
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_BUFFERING,
      position: {
        elapsedTime: 0,
        updateTime: new Date().getTime(),
      }
    };
    (await this.session).setAVPlaybackState(playbackState)
  }
}

/**
 * 获取播放时间(ms)
 * @returns number 播放时间(ms)
 */
async function getPlayTime(): Promise<number> {
  let resTime = 0
  let elapsedTime:number | undefined = await AppStorage.get('player-time')
  if(elapsedTime) {
    resTime = elapsedTime
  }
  return resTime
}

const avSessionUtils = new AVSessionUtils()
export default avSessionUtils as AVSessionUtils