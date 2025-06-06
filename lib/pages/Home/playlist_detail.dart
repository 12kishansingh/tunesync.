import 'package:flutter/material.dart';
import 'package:tunesync/services/discogsapi.dart';

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
    final data = await DiscogsAPI.searchGenre(widget.playlistName); // Simulated as genre
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
                ? Image.network(item['cover_image'], width: 50, height: 50)
                : const Icon(Icons.music_note),
            title: Text(item['title'] ?? 'Unknown Song'),
            subtitle: Text(item['type'] ?? ''),
          );
        },
      ),
    );
  }
}
