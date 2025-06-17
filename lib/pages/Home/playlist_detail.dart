import 'package:flutter/material.dart';
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
              final audioService =
                  Provider.of<AudioPlayerService>(context, listen: false);

              // Create song object with explicit String type casting - FIXED
              final Map<String, String> song = {
                'title': item['title']?.toString() ?? 'Unknown Song',
                'artist': item['type']?.toString() ?? 'Unknown Artist',
                'imageUrl': item['cover_image']?.toString() ?? '',
                'audioUrl':
                    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
              };

              // Create playlist for navigation - already correctly typed
              final playlist = _tracks
                  .map<Map<String, String>>((track) => {
                        'title': track['title']?.toString() ?? 'Unknown Song',
                        'artist': track['type']?.toString() ?? 'Unknown Artist',
                        'imageUrl': track['cover_image']?.toString() ?? '',
                        'audioUrl':
                            'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
                      })
                  .toList();

              // Play the selected song with playlist context
              audioService.playSong(song, playlist: playlist, index: index);
            },
          );
        },
      ),
    );
  }
}
