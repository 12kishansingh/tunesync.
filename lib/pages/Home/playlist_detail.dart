import 'package:flutter/material.dart';
import 'package:tunesync/model/track.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:tunesync/services/discogsapi.dart';
import 'package:provider/provider.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;

  const PlaylistDetailPage({super.key, required this.playlistName});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  List<dynamic> _tracks = [];

  @override
  void initState() {
    super.initState();
    fetchPlaylistTracks();
  }

  Future<void> fetchPlaylistTracks() async {
    final data = await DiscogsAPI.searchGenre(widget.playlistName);
    if (data != null && data['results'] != null) {
      setState(() {
        _tracks = data['results'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlistName)),
      body: ListView.builder(
        itemCount: _tracks.length,
        itemBuilder: (context, index) {
          final item = _tracks[index];
          return ListTile(
            leading: item['cover_image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item['cover_image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.music_note),
                    ),
                  )
                : const Icon(Icons.music_note),
            title: Text(item['title'] ?? 'Unknown Song'),
            subtitle: Text(item['type'] ?? ''),
            trailing: const Icon(Icons.play_arrow),
            onTap: () {
              final audioService = Provider.of<AudioPlayerService>(context, listen: false);
              
              // Convert dynamic tracks to Track objects
              final trackList = _tracks.map<Track>((track) {
                return Track(
                  id: track['id']?.toString() ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
                  title: track['title']?.toString() ?? 'Unknown Song',
                  artist: track['type']?.toString() ?? 'Unknown Artist',
                  coverUrl: track['cover_image']?.toString() ?? '',
                );
              }).toList();

              // Play the selected track with playlist context
              audioService.playPlaylist(trackList, index);
            },
          );
        },
      ),
    );
  }
}
