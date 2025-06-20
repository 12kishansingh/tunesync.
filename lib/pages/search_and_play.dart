import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:tunesync/services/youtube_music_service.dart';
import 'package:tunesync/services/discogsapi.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Track {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;

  Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
  });
}

class SearchAndPlayPage extends StatefulWidget {
  const SearchAndPlayPage({super.key});

  @override
  State<SearchAndPlayPage> createState() => _SearchAndPlayPageState();
}

class _SearchAndPlayPageState extends State<SearchAndPlayPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Track> _results = [];
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Nothing is entered to search';
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final videos = await YouTubeMusicService.searchSongs(query);

      final tracks = await Future.wait(videos.map((video) async {
        final discogs = await DiscogsAPI.searchTrack(video.title);
        String artist = '';
        String coverUrl = video.thumbnails.mediumResUrl;

        if (discogs != null &&
            discogs['results'] != null &&
            discogs['results'].isNotEmpty) {
          artist = discogs['results'][0]['artist'] ?? '';
          coverUrl = discogs['results'][0]['cover_image'] ?? coverUrl;
        }

        return Track(
          id: video.id.value,
          title: video.title,
          artist: artist,
          coverUrl: coverUrl,
        );
      }));

      setState(() {
        _results = tracks;
        _loading = false;
        if (_results.isEmpty) {
          _errorMessage = 'No results found for "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Search failed: ${e.toString()}';
      });
    }
  }

  void onTrackSelected(Track track) async {
    final audioService = Provider.of<AudioPlayerService>(context, listen: false);
    final url = await YouTubeMusicService.getAudioUrl(track.id);

    if (url.isNotEmpty) {
      await audioService.playDirect(
        url,
        title: track.title,
        artist: track.artist,
        imageUrl: track.coverUrl,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio stream not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _searchFocusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search for songs, artists...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        // Removed suffixIcon from here
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Search icon outside the TextField
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
                  if (_results.isEmpty) {
                    return const Center(
                      child: Text(
                        'Search for songs above.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final track = _results[index];
                      return ListTile(
                        leading: Image.network(
                          track.coverUrl,
                          width: 50,
                          height: 50,
                          errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                        ),
                        title: Text(track.title),
                        subtitle: Text(track.artist),
                        onTap: () => onTrackSelected(track),
                      );
                    },
                  );
                },
              ),
            ),
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
                            color: Colors.white,
                          ),
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
                              fontWeight: FontWeight.bold,
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
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (audioService.isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.play();
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
