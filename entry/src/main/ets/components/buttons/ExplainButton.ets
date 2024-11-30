@Component
export struct ExplainButton {
  build() {
    Button() {
      Image($r('app.media.ic_public_help'))
        .fillColor($r('app.color.reverse'))
        .width(15)
    }
    .type(ButtonType.Circle)
    .backgroundColor(Color.Transparent)
  }
}