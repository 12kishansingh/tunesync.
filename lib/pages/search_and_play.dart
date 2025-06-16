import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:tunesync/services/youtube_music_service.dart';
import 'package:tunesync/services/discogsapi.dart';

class SearchAndPlayPage extends StatefulWidget {
  const SearchAndPlayPage({super.key});

  @override
  State<SearchAndPlayPage> createState() => _SearchAndPlayPageState();
}

class _SearchAndPlayPageState extends State<SearchAndPlayPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    setState(() { _loading = true; });
    final results = await YouTubeMusicService.searchSongs(_controller.text);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Music + Discogs')),
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
                      hintText: 'Search for a song...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final song = _results[index];
                return ListTile(
                  leading: Image.network(
                    song['thumbnail'] ?? '', 
                    width: 50, 
                    height: 50, 
                    errorBuilder: (_, __, ___) => const Icon(Icons.music_note)
                  ),
                  title: Text(song['title'] ?? ''),
                  subtitle: Text(song['artist'] ?? ''),
                  onTap: () async {
                    // Get Discogs metadata (optional)
                    final discogs = await DiscogsAPI.searchTrack(song['title'] ?? '');
                    String? discogsImage;
                    if (discogs != null && 
                        discogs['results'] != null && 
                        (discogs['results'] as List).isNotEmpty) {
                      discogsImage = discogs['results'][0]['cover_image'];
                    }
                    
                    // Get audio URL from YouTube
                    final url = await YouTubeMusicService.getAudioUrl(song['id']!);
                    if (url != null) {
                      // Use playDirect method with correct parameters
                      await audioService.playDirect(
                        url,
                        title: song['title'],
                        artist: song['artist'],
                        imageUrl: discogsImage ?? song['thumbnail'],
                      );
                    }
                  },
                );
              },
            ),
          ),
          // Mini player at bottom
          if (audioService.currentTitle != null)
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (audioService.currentImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        audioService.currentImageUrl!, 
                        width: 50, 
                        height: 50, 
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.music_note, 
                          color: Colors.white
                        )
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          audioService.currentTitle ?? '', 
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          audioService.currentArtist ?? '', 
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      audioService.isPlaying ? Icons.pause : Icons.play_arrow, 
                      color: Colors.white
                    ),
                    onPressed: () {
                      if (audioService.isPlaying) {
                        audioService.pause();
                      } else {
                        audioService.play(); // Use play() instead of resume()
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
