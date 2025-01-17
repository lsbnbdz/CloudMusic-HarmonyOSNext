export class DataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = []
  originDataArray: T[] = []

  totalCount(): number {
    return this.originDataArray.length;
  }

  getAllData(): T[] {
    return this.originDataArray
  }

  getData(index: number) {
    return this.originDataArray[index]
  }

  addData(index: number, data: T): void {
    this.originDataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  pushData(data: T): void {
    this.originDataArray.push(data)
    this.notifyDataAdd(this.originDataArray.length - 1)
  }

  pushDataArray(...items: T[]): void {
    for (let data of items) {
      this.originDataArray.push(data)
      this.notifyDataAdd(this.originDataArray.length - 1)
    }
  }

  deleteData(index: number): void {
    this.originDataArray.splice(index, 1)
    this.notifyDataDelete(index)
  }

  setData(dataArray?: T[]): void {
    if (dataArray) {
      this.originDataArray = dataArray
    } else {
      this.originDataArray = []
    }
    setTimeout(() => {
      this.notifyDataReload()
    })
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener)
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1)
    }
  }

  notifyDataReload() {
    this.listeners.forEach(listener => {
      listener.onDataReloaded()
    })
  }

  notifyDataAdd(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  notifyDataMove(from: number, to: number) {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }

  notifyDataDelete(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  notifyDataChange(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }
}