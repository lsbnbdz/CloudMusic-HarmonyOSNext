/**
 * 消息内容常量
 */
export class MsgConstants {
  /**
   * 网络请求 HTTP Request 错误
   */
  static readonly HTTP_ERROR: string = '网络请求发生错误，请检查\n网络连接和API服务器是否正常'
  /**
   * 如何登录
   */
  static readonly HOW_TO_LOGIN_MSG: string = '请先耐心等待网页加载，之后在当前网页中登录你的账号\n' +
    '（点击登录弹窗下方的“选择其他登录方式”可以使用更多方法登录）\n\n' +
    '待开始转圈加载或登录完成后，点击下方按钮，之后等待登录完成\n'
  /**
   * 功能开发中的提示
   */
  static readonly DEVELOPING: string = '该功能正在开发中，敬请期待。'
  /**
   * 正在下载提示
   */
  static readonly DOWNLOADING: string = '正在下载'
  /**
   * 缓存完成提示
   */
  static readonly DOWNLOAD_COMPLETE: string = '下载完成'
}