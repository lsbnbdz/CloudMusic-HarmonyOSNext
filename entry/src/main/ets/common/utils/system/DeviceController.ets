import { vibrator } from "@kit.SensorServiceKit";
import { BusinessError } from "@kit.BasicServicesKit";


export class VibrationControl {

  /**
   * preset类型震动,默认1次，强度100(0-100)
   * @param count
   */
  static handlePresetVibration(count: number = 1, intensity: number = 100){
    try {
      // 查询是否支持'haptic.clock.timer'
      const effectId: string = 'haptic.clock.timer'
      vibrator.isSupportEffect(effectId).then((state: boolean) => {
        console.info(`The query result is ${state}`);
        if (state) {
          try {
            vibrator.startVibration({
              type: 'preset',
              effectId: effectId,
              count: count,
              intensity: intensity
            }, {
              usage: 'unknown'
            }).then(() => {
              console.info('Succeed in starting vibration');
            }).catch((error: BusinessError) => {
              console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
            });
          } catch (error) {
            let e: BusinessError = error as BusinessError;
            console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
          }
        }
      }, (error: BusinessError) => {
        console.error(`Failed to query effect. Code: ${error.code}, message: ${error.message}`);
      })
    } catch (error) {
      let e: BusinessError = error as BusinessError;
      console.error(`An unexpected error occurred. Code: ${e.code}, message: ${e.message}`);
    }
  }
}


