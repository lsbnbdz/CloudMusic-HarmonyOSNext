import Constants from "../../common/constants/Constants"

@CustomDialog
export struct WarrantyDialog {
  controller: CustomDialogController
  scroller: Scroller = new Scroller()

  build() {
    Column({ space: 20 }) {
      Text('使用条款和免责声明')
        .fontSize(Constants.FONT_SIZE_TITLE)
        .fontWeight(FontWeight.Bold)
      Scroll(this.scroller) {
        this.Content()
      }
      .layoutWeight(1)
      .height('100%')

      Button('我已知晓')
        .onClick(() => {
          this.controller.close()
        })
    }
    .backgroundColor($r('app.color.background'))
    .padding({ top: Constants.PADDING_EDGE_TEXT, bottom: Constants.PADDING_EDGE_TEXT })
    .constraintSize({
      minWidth: 100,
      maxWidth: 400,
      maxHeight: 600
    })
  }

  @Builder Content() {
    Column() {
      Text(`📜 使用须知\n`)
        .textStyle(true)

      Text(`【第三方服务声明】\n` +
        `     本应用为基于开源项目开发的第三方音乐应用，仅提供前端界面。\n\n` +
        `【数据来源说明】\n` +
        `     所有音乐内容均通过用户自行配置的API地址获取，应用本身：\n` +
        `     - 不联网上传任何数据\n` +
        `     - 不维护任何数据服务器\n\n` +
        `【配置责任提醒】\n` +
        `     您知晓并同意：\n` +
        `     - 确保配置的API来源合法合规\n` +
        `     - 不得将本应用用于商业用途\n` +
        `     - 不得通过本应用实施侵权行为\n\n`)
        .textStyle()

      // 免责声明部分
      Text(`⚠️ 免责声明\n`)
        .textStyle(true)

      Text(`【版权声明】\n` +
        `     - 音乐作品版权归属网易云音乐/原始权利人所有\n` +
        `     - 本应用与版权方无任何授权/合作关系\n\n` +
        `【开发声明】\n` +
        `     - 基于 NeteaseCloudMusicApi (MIT协议) 开发\n` +
        `     - 源代码已开源\n\n` +
        `【责任限制】\n` +
        `     开发者不承担因以下情况导致的任何责任：\n` +
        `     - API服务失效或数据异常\n` +
        `     - 用户滥用引发的版权纠纷\n` +
        `     - 违反当地法律法规的使用行为\n\n` +
        `继续使用本应用代表您已知晓且同意使用条款和免责声明。`)
        .textStyle()

    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
  }
}

@Extend(Text) function textStyle(isBold: boolean = false) {
  .fontSize(isBold ? Constants.FONT_SIZE_TITLE - 2 : Constants.FONT_SIZE_COMMON)
  .fontWeight(isBold ? FontWeight.Bold : FontWeight.Regular)
  .lineHeight(25)
  .fontColor($r('app.color.reverse'))
  .width('100%')
}