const _arrStr: string[] = ['发现', '歌单', '我的'];

@Builder
export function myCustomTitle(pageInfos: NavPathStack, titleOpacity: number[], index: number){
  Stack({ alignContent: Alignment.Bottom }){

    Row(){}
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])
    .height('100%')
    .width('100%')
    .linearGradient({
      colors: [
        ['transparent', 0.00],
        [$r('app.color.title_background'), 1.00]
      ],
      angle: 0
    })
    .linearGradientBlur(5, {
      fractionStops: [
        [0.00 , 0.00],
        [0.99 , 1.00]
      ],
      direction: GradientDirection.Bottom
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])

    Row(){
      Text(_arrStr[index])
        .fontColor($r('app.color.reverse'))
        .fontWeight(FontWeight.Bold)
        .fontSize(30)
        .backgroundColor('transparent')
      Button({ type: ButtonType.Circle, stateEffect: true }){
        Image($r('app.media.ic_public_search_filled'))
          .width(25)
          .onClick(() => {
            pageInfos.clear()
            pageInfos.pushPathByName('SearchPage', null, true)
          })
          .fillColor($r('app.color.reverse'))
          .backgroundColor('transparent')
      }
      .backgroundBlurStyle(5)
      .backgroundColor($r('app.color.btn_background'))
      .width(40)
      .height(40)
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP ,SafeAreaEdge.BOTTOM])
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: '50px',
      right: '50px',
    })

  }
  .opacity(titleOpacity[index])
}