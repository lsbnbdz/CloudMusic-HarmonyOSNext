export interface ArtistItem {
  artistId: number
  artistName: string
  artistAvatarPicUrl: string
}

interface Data {
  totalCount: number
  list: ArtistItem[]
}

export interface ArtistsResult {
  code: number
  data: Data
}