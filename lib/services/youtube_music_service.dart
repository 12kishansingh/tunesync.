import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeMusicService {
  static final YoutubeExplode _yt = YoutubeExplode();

  // Search for songs on YouTube Music
  static Future<List<Map<String, String>>> searchSongs(String query) async {
    final results = await _yt.search.search(query, filter: TypeFilters.video);
    return results.take(20).map((video) => {
      'id': video.id.value,
      'title': video.title,
      'artist': video.author,
      'duration': video.duration?.toString() ?? '',
      'thumbnail': video.thumbnails.highResUrl,
    }).toList();
  }

  // Get audio stream URL for playback
  static Future<String?> getAudioUrl(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    final audio = manifest.audioOnly.withHighestBitrate();
    return audio.url.toString();
  }

  static void dispose() {
    _yt.close();
  }
}
