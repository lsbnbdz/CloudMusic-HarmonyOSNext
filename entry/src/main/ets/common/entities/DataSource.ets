import { PlayQueue } from './PlayQueue';

abstract class DataSource<T> implements IDataSource {

  private mDataSource: T[] = new Array()

  constructor(dataList: T[]) {
    this.mDataSource = dataList
  }

  totalCount(): number {
    return this.mDataSource == null ? 0 : this.mDataSource.length
  }

  getData(index: number): T | null {
    return index >= 0 && index < this.totalCount() ? this.mDataSource[index] : null
  }

  registerDataChangeListener(listener: DataChangeListener) {
  }

  unregisterDataChangeListener(listener: DataChangeListener) {
  }

}

/**
 * 播放列表数据源
 */
export class PlayQueueDataSource extends DataSource<PlayQueue> {
  constructor(queue: Array<PlayQueue>) {
    super(queue)
  }
}