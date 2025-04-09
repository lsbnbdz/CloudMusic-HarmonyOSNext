export class EmitterConstants {
  /**
   * 播放界面显示事件
   */
  static readonly PLAYING_COVER_TOGGLE: string = 'PLAYING_COVER_TOGGLE'
  /**
   * Emitter
   * 更新歌词
   */
  static readonly EMITTER_LYRIC_UPDATE: string = 'LYRIC_UPDATE'
  /**
   * Emitter
   * 更新搜索内容
   */
  static readonly EMITTER_SEARCH: string = 'SEARCH'
  /**
   * Emitter
   * 刷新播放列表
   */
  static readonly EMITTER_REFRESH_PLAYQUEUE: string = 'REFRESH_PLAYQUEUE'
  /**
   * 刷新LocalSong列表
   */
  static readonly REFRESH_LOCALSONGS: string = 'REFRESH_LOCALSONGS'
  /**
   * 从歌单中删除歌曲
   */
  static readonly EMITTER_DELETE_FROM_PLAYLIST: string = 'DELETE_FROM_PLAYLIST'
  /**
   * 播放
   */
  static readonly PLAY_PLAYLIST_SONGS: string = 'PLAY_PLAYLIST_SONGS'
  /**
   * Push页面
   */
  static readonly PUSH_PAGE: string = 'PUSH_PAGE'
}