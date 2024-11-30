import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import AudioPlayUtils from './AudioPlayUtils';
import { LogUtil } from '@pura/harmony-utils';
import { Song } from '../entities/SongsResult';

/**
 * 长时任务
 * （音频播放）
 */
const TAG = '[ContinuousTask] '

class ContinuousTask {
  private context: Context = getContext(this);

  startTask(song:Song, artists:string, picUrl:string ,url:string) {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "cc.chenlvin.cloudmusic",
          abilityName: "EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      backgroundTaskManager.startBackgroundRunning(this.context,
        backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj).then(async () => {
        // 具体长时任务逻辑
        const session = await avSession.createAVSession(this.context, 'playSession', 'audio')
        await session.activate()

        AudioPlayUtils.play(url)
        LogUtil.info(`启动长时任务 stopBackgroundRunning.`);
        AudioPlayUtils.mPlayer.onStateChange((state) => {
          if(state == 'paused') { AppStorage.setOrCreate('player-ispaused', true) }
          if(state == 'idle') { session.destroy() }
          if(state == 'stopped') { AppStorage.setOrCreate('player-ispaused', true); session.destroy() }
          if(state == 'completed') { AppStorage.setOrCreate('player-ispaused', true); session.destroy() }
        })
      }).catch((err: BusinessError) => {
        LogUtil.error(`开启长时任务 startBackgroundRunning 失败：Code - ${err.code}, Message - ${err.message}`);
      });
    });
  }

  async stopTask() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      LogUtil.info(`成功结束长时任务 stopBackgroundRunning.`);
    }).catch((err: BusinessError) => {
      LogUtil.error(`结束长时任务 stopBackgroundRunning 失败：Code - ${err.code}, Message - ${err.message}`);
    });
  }
}

const conTask = new ContinuousTask()
export default conTask as ContinuousTask