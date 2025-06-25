import 'package:tunesync/model/track.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeMusicService {
  static final YoutubeExplode _yt = YoutubeExplode();

  // Search for videos matching query
  static Future<List<Video>> searchSongs(String query) async {
    try {
      final search = await _yt.search.search(query);
      return search.toList();
    } catch (e) {
      print('YouTube search error: $e');
      return [];
    }
  }

  // Get audio stream URL for a video ID
  static Future<String> getAudioUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      print('Failed to get audio stream: $e');
      return '';
    }
  }

  // Get audio stream URL using track metadata
  static Future<String> getYoutubeStreamUrl(String title, String artist) async {
    try {
      final searchQuery = '$title $artist audio';
      final results = await searchSongs(searchQuery);
      if (results.isEmpty) return '';
      return await getAudioUrl(results.first.id.value);
    } catch (e) {
      print('Stream URL fetch error: $e');
      return '';
    }
  }

  // Get playlist tracks by YouTube playlist ID
  static Future<List<Track>> getPlaylistTracks(String ytid) async {
    try {
      List<Track> tracks = [];
      await for (var video in _yt.playlists.getVideos(ytid)) {
        tracks.add(Track(
          id: video.id.value,
          title: video.title,
          artist: video.author,
          coverUrl: video.thumbnails.highResUrl,
        ));
      }
      return tracks;
    } catch (e) {
      print('Error fetching playlist tracks: $e');
      return [];
    }
  }

  // Close when done (call in app's dispose)
  static void close() => _yt.close();
}
