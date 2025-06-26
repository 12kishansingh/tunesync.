import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/model/track.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:tunesync/pages/full_screen_page.dart';
import 'package:tunesync/services/youtube_music_service.dart';
// Import your search page
import 'package:tunesync/pages/search_and_play.dart'; // <-- Update this import if needed

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final String playlistSubtitle;
  final String playlistImageUrl;
  final String genre;
  final String ytid;

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
    required this.playlistSubtitle,
    required this.playlistImageUrl,
    required this.genre,
    required this.ytid,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<Track> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  Future<void> _fetchTracks() async {
    try {
      if (widget.ytid.isNotEmpty) {
        _tracks = await YouTubeMusicService.getPlaylistTracks(widget.ytid);
      } else {
        _tracks = [];
      }
    } catch (e) {
      print('Error fetching tracks: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _playTrack(int index) {
    final audioService = Provider.of<AudioPlayerService>(context, listen: false);
    audioService.playPlaylist(_tracks, index);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FullScreenPlayer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.playlistName, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchAndPlayPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Playlist image and info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.playlistImageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.playlistName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.playlistSubtitle,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Genre: ${widget.genre}",
                              style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey),
                // Track list
                Expanded(
                  child: _tracks.isEmpty
                      ? const Center(
                          child: Text(
                            "No tracks found.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tracks.length,
                          itemBuilder: (context, index) {
                            final track = _tracks[index];
                            return ListTile(
                              leading: track.coverUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        track.coverUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[800],
                                          child: const Icon(Icons.music_note, color: Colors.white),
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.music_note, color: Colors.white),
                              title: Text(
                                track.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                track.artist,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                                onPressed: () => _playTrack(index),
                              ),
                              onTap: () => _playTrack(index),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
