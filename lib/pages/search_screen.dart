import 'package:flutter/material.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:tunesync/services/discogsapi.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/youtube_music_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _loading = false;
  String? _errorMessage;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Nothing is entered to search';
        _searchResults = [];
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final results = await DiscogsAPI.searchTracks(query);
      setState(() {
        _searchResults = results;
        _loading = false;
        if (_searchResults.isEmpty) {
          _errorMessage = 'No results found for "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Discogs Track Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Search for a track...',
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (_errorMessage != null) {
                  return Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                if (_searchResults.isEmpty) {
                  return const Center(
                    child: Text(
                      'Search for tracks above.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final track = _searchResults[index];
                    return ListTile(
                      leading: track['cover_image'] != null
                          ? Image.network(track['cover_image'], width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.music_note),
                      title: Text(track['title'] ?? 'Unknown Title'),
                      subtitle: Text(track['artist'] ?? track['artist_sort'] ?? 'Unknown Artist'),
                      onTap: () async {
                        await _playTrack(context, track, audioService);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playTrack(BuildContext context, dynamic track, AudioPlayerService audioService) async {
    try {
      final artist = track['artist'] ?? track['artist_sort'] ?? '';
      final title = track['title'] ?? '';
      final url = await YouTubeMusicService.getYoutubeStreamUrl(title, artist);
      if (url != null) {
        await audioService.playDirect(
          url,
          title: title,
          artist: artist,
          imageUrl: track['cover_image'] ?? '',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playing "$title" by $artist')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stream not found for "$title"')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing track: $e')),
      );
    }
  }
}
