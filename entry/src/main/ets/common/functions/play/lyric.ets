import { Lyric } from "../../entities/Lyric";
import LyricUtils from "../../utils/play/LyricUtils";

/**
 * Get Lyric Objects
 * @returns Array<Lyric>
 */
export function getLyricObjects(): Lyric[] {
  return LyricUtils.lyricObjects
}

