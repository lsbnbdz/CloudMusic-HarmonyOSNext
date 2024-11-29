import { bundleManager, wantAgent } from '@kit.AbilityKit'
import { avSession } from '@kit.AVSessionKit'
import { backgroundTaskManager } from '@kit.BackgroundTasksKit'

class BackgroundRunningManager {
  async startBackgroundRunning() {
    const context = getContext()
    const session = await avSession.createAVSession(context, 'guardianSession', 'audio')
    await session.activate()
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    const wantAgentObj = await wantAgent.getWantAgent({
      wants: [{ bundleName: bundleInfo.name, abilityName: "EntryAbility" }],
      requestCode: 0,
    })
    await backgroundTaskManager.startBackgroundRunning(context,
      backgroundTaskManager.BackgroundMode.AUDIO_PLAYBACK, wantAgentObj)
  }

  async stopBackgroundRunning() {
    backgroundTaskManager.stopBackgroundRunning(getContext())
  }
}

const backgroundRunningManager = new BackgroundRunningManager()
export default backgroundRunningManager as BackgroundRunningManager
