import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { LogUtil } from '@pura/harmony-utils';

/**
 * 长时任务
 * （音频播放）
 */
const TAG = '[ContinuousTask] '

class ContinuousTask {
  private context: Context = getContext(this)

  /**
   * 开始播放任务
   * @param mode 0:fileUrl, 1:url
   * @param song
   * @param artists
   * @param picUrl
   * @param url
   */
  async startTask() {
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
        LogUtil.info(TAG + `启动长时任务 stopBackgroundRunning.`);
      }).catch((err: BusinessError) => {
        LogUtil.error(TAG + `开启长时任务 startBackgroundRunning 失败：Code - ${err.code}, Message - ${err.message}`);
      });
    });
  }

  async stopTask() {
    backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
      LogUtil.info(TAG + `成功结束长时任务 stopBackgroundRunning.`);
    }).catch((err: BusinessError) => {
      LogUtil.error(TAG + `结束长时任务 stopBackgroundRunning 失败：Code - ${err.code}, Message - ${err.message}`);
    });
  }
}

const conTask = new ContinuousTask()
export default conTask as ContinuousTask