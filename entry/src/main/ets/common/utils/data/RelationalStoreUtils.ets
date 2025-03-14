import { relationalStore } from '@kit.ArkData'
import { LogUtil } from '@pura/harmony-utils'
import { LocalSong } from '../../entities/LocalData'

const TAG = '[RelationalStoreUtils] '
const STORE_CONFIG: relationalStore.StoreConfig = {
  name: 'LocalSongs.db',
  securityLevel: relationalStore.SecurityLevel.S1,
  encrypt: false
}
const TABLE_SONGS = 'songs'

class RelationalStoreUtils {
  private store: relationalStore.RdbStore = {} as relationalStore.RdbStore

  async init() {
    try {
      this.store = await relationalStore.getRdbStore(getContext(), STORE_CONFIG)
    } catch (e) {
      LogUtil.error(TAG + 'Init Store Error: ' + e.message)
    }
    await this.createTables()
  }

  private async createTables() {
    const createTableSql = `
      CREATE TABLE IF NOT EXISTS ${TABLE_SONGS} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        songId INTEGER,
        name TEXT NOT NULL,
        artists TEXT NOT NULL,
        songFile TEXT NOT NULL,
        picFile TEXT,
        lyricFile TEXT
      )`

    try {
      await this.store.executeSql(createTableSql)
    } catch (err) {
      LogUtil.error(TAG + 'Failed to create table: ' + err.message)
    }
  }

  async addSong(item: LocalSong) {
    const valueBucket: relationalStore.ValuesBucket = {
      'songId': item.songId,
      'name': item.name,
      'artists': item.artists,
      'songFile': item.songFile,
      'picFile': item.picFile,
      'lyricFile': item.lyricFile
    }

    try {
      return await this.store.insert(TABLE_SONGS, valueBucket)
    } catch (e) {
      LogUtil.error(TAG + 'Insert song Error: ' + e.message)
      return -1
    }
  }

  /**
   * 获取所有歌曲
   * @returns LocalSong[]
   */
  async getAllSongs(): Promise<LocalSong[]> {
    const columns = ['id', 'name', 'artists', 'picFile', 'songFile', 'lyricFile']
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)

    try {
      const resultSet = await this.store.query(predicates, columns)
      return await this.parseResultSet(resultSet)
    } catch (e) {
      LogUtil.error(TAG + 'Failed to get songs: ' + e.message)
      return []
    }
  }

  /**
   * 解析查询结果
   * @param resultSet
   * @returns
   */
  private async parseResultSet(resultSet: relationalStore.ResultSet): Promise<LocalSong[]> {
    const list: LocalSong[] = []
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getDouble(resultSet.getColumnIndex('id')),
        songId: resultSet.getDouble(resultSet.getColumnIndex('songId')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        artists: resultSet.getString(resultSet.getColumnIndex('artists')),
        picFile: resultSet.getString(resultSet.getColumnIndex('picFile')),
        songFile: resultSet.getString(resultSet.getColumnIndex('songFile')),
        lyricFile: resultSet.getString(resultSet.getColumnIndex('lyricFile'))
      })
    }
    return list
  }

  /**
   * 删除
   * @param id
   * @returns
   */
  async deleteSong(id: number): Promise<number> {
    const predicates = new relationalStore.RdbPredicates(TABLE_SONGS)
      .equalTo('id', id)
    try {
      return await this.store.delete(predicates)
    } catch (e) {
      LogUtil.error(TAG + 'Delete Error: ' + e.message)
      return 0
    }
  }
}

const relationalStoreUtils = new RelationalStoreUtils()
export default relationalStoreUtils as RelationalStoreUtils