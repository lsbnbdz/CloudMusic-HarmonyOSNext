export interface ArtistItem {
  id: number,
  name: string,
  picUrl: string
}

interface Body {
  artistCount: number
  artists: ArtistItem[]
}

export interface ArtistsResult {
  result: Body
}