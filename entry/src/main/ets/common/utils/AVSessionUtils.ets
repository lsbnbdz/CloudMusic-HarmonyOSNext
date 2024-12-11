import { avSession } from "@kit.AVSessionKit";
import { AppUtil, LogUtil } from "@pura/harmony-utils";
import { Song } from "../entities/SongsResult";
import { changeCycleMode, pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../functions/playerControl";

/**
 * AVSession 播控中心工具类
 */
const TAG = '[AVSessionUtils] '

class AVSessionUtils {
  context = AppUtil.getContext()
  session = this.createSession()

  private isActivating = false
  private cycleMode: number = 0

  async createSession(): Promise<avSession.AVSession> {
    if(this.session) {
      return this.session
    }
    let session = await avSession.createAVSession(this.context, 'playSession', 'audio')
    try {
      let cycleMode: number | undefined = AppStorage.get('cycleMode')
      if(cycleMode) this.cycleMode = this.cycleMode
      else this.cycleMode = 0

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
      session.on('seek', (time) => {
        seekMusic(time)
      })
      session.on('setLoopMode', (loopMode) => {
        if(loopMode == 0) { changeCycleMode(1) }
        else if(loopMode == 1) { changeCycleMode(2) }
        else if(loopMode == 2) { changeCycleMode(3) }
        else { changeCycleMode(0) }

      })



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
    if (this.isActivating) return; // 防止重复调用
    this.isActivating = true;
    try {
      await (await this.session).activate();
    } finally {
      this.isActivating = false;
    }
  }

  /**
   * 停用
   */
  async deactive() {
    if (this.isActivating) return; // 等待激活完成
    try {
      await (await this.session).deactivate();
    } catch (e) {
      LogUtil.error(TAG + '停用失败: ' + e);
    }
  }

  /**
   * 设置为播放状态
   */
  async playState() {
    let loopMode = await getLoopMode()
    let time = await getPlayTime()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      loopMode: loopMode,
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

async function getLoopMode(): Promise<number> {
  let loopMode = 0
  let cycleMode: number | undefined = await AppStorage.get('cycleMode')
  if(cycleMode) {
    loopMode = cycleMode
  }
  return loopMode
}

const avSessionUtils = new AVSessionUtils()
export default avSessionUtils as AVSessionUtils