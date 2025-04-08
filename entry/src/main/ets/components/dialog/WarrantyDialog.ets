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
      Text('更新日期: 2025/3/9')
        .padding({ bottom: 20 })
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor($r('app.color.reverse'))

      Text(`📜 使用须知\n`)
        .textStyle(true)

      Text(`【第三方服务声明】\n` +
        `本应用为开源项目，基于第三方API开发，仅提供前端界面。\n\n` +
        `【数据来源说明】\n` +
        `所有音乐内容均通过用户自行配置的API地址获取，应用本身不提供任何音乐内容。\n\n` +
        `应用需要用户手动配置API服务器地址才可启用在线服务，应用提供的默认API地址仅为测试用例，仅供学习与测试使用，用户设置任意API均视为同意该条款，该应用造成的风险和责任由用户自行承担，本应用与开发者不承担任何责任。\n\n` +
        `【配置责任提醒】\n` +
        `您知晓并同意：\n` +
        `     - 确保配置的API来源合法合规\n` +
        `     - 不得将本应用用于商业用途\n` +
        `     - 不得通过本应用实施侵权行为\n\n`)
        .textStyle()

      // 免责声明部分
      Text(`⚠️ 免责声明\n`)
        .textStyle(true)

      Text(`本应用为第三方开源客户端，仅提供音乐播放界面，不分发任何受版权保护的内容。 请注意：\n` +
        `     本应用本身不提供音乐数据，部分功能使用第三方API服务，仅供个人学习使用，禁止用于商业用途。\n` +
        `     用户需对自行配置的API合法性负责，禁止用于商业或侵权行为。\n` +
        `     音乐版权归属原始权利人，应用与其无任何关联。\n\n` +
        `本项目开发者承诺严格遵守相关法律法规，不承担因滥用导致的版权纠纷等风险，请通过官方渠道支持创作者。\n\n` +
        `继续使用本应用代表您已知晓且同意使用条款和免责声明。\n\n`)
        .textStyle()

      // 开源许可
      Text(`⚖️ 开源许可\n`)
        .textStyle(true)

      Text('').textStyle()

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