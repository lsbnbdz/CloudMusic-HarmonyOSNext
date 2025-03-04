import { common, Want } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { LogUtil, ToastUtil } from "@pura/harmony-utils";

export function openInWeb(url: string) {
  if (getContext()) {
    let context = getContext() as common.UIAbilityContext;
    let want: Want = {
      action: 'ohos.want.action.viewData',
      entities: ['entity.system.browsable'],
      uri: url
    }
    context.startAbility(want)
      .catch((e: BusinessError) => {
        LogUtil.error('打开浏览器失败: ' + e.message)
      })
  } else {
    ToastUtil.showToast('打开浏览器失败')
  }
}