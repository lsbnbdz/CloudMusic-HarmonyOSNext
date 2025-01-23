import { notificationManager } from "@kit.NotificationKit"
import { AppUtil, LogUtil } from "@pura/harmony-utils"

/**
 * 通知类
 */
const TAG = '[NotificationUtils] '
class NotificationUtils {
  /**
   * 发布普通通知
   * @param id
   * @param text
   */
  publish(id: number, title: string, text: string) {
    let contentType = notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT
    notificationManager.publish({
      id: id,
      deliveryTime: new Date().getTime(),
      showDeliveryTime: true,
      content: {
        notificationContentType: contentType,
        normal: {
          title: title,
          text: text,
        }
      },
    }).then(() => {
      LogUtil.info(TAG + '成功发送通知')
    })
      .catch((err:Error) => {
      LogUtil.info(TAG + '发送通知失败' + err.message)
    })
  }

  /**
   * 取消通知
   * @param id
   */
  cancel(id: number) {
    notificationManager.cancel(id, () => {})
  }

  /**
   * 取消所有通知
   */
  cancelAll() {
    notificationManager.cancelAll()
  }
}

const notificationUtils = new NotificationUtils()
export default notificationUtils as NotificationUtils