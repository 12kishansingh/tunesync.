import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunesync/model/track.dart';// Import Track model
import 'package:tunesync/services/youtube_music_service.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Track> _playlist = [];
  int _currentIndex = -1;
  String? _currentImageUrl;

  // Current state for backwards compatibility
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Streams for UI consumption
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get isPlayingStream => 
      _audioPlayer.playerStateStream.map((state) => state.playing).distinct();

  // Getters for backwards compatibility
  AudioPlayer get audioPlayer => _audioPlayer;
  String? get currentTitle => _currentIndex >= 0 ? _playlist[_currentIndex].title : null;
  String? get currentArtist => _currentIndex >= 0 ? _playlist[_currentIndex].artist : null;
  String? get currentImageUrl => _currentImageUrl;
  bool get isPlaying => _audioPlayer.playing;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  Duration get duration => _duration;
  Duration get position => _position;

  AudioPlayerService() {
    // Handle track completion
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
      notifyListeners();
    });

    // Update duration and position for backwards compatibility
    _audioPlayer.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });
  }

  // Play single track directly (backwards compatibility)
  Future<void> playDirect(String url, {String? title, String? artist, String? imageUrl}) async {
    try {
      _playlist = [Track(
        id: 'direct',
        title: title ?? 'Unknown',
        artist: artist ?? 'Unknown',
        coverUrl: imageUrl ?? '',
      )];
      _currentIndex = 0;
      _currentImageUrl = imageUrl;
      
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      print("Error playing direct: $e");
    }
  }

  // Play song with playlist context (backwards compatibility)
  Future<void> playSong(Map<String, String> song, {List<Map<String, String>>? playlist, int index = 0}) async {
    try {
      if (playlist != null) {
        // Convert old format to new Track format
        _playlist = playlist.map((item) => Track(
          id: item['audioUrl'] ?? 'unknown',
          title: item['title'] ?? 'Unknown',
          artist: item['artist'] ?? 'Unknown',
          coverUrl: item['imageUrl'] ?? '',
        )).toList();
        _currentIndex = index;
      } else {
        _playlist = [Track(
          id: song['audioUrl'] ?? 'unknown',
          title: song['title'] ?? 'Unknown',
          artist: song['artist'] ?? 'Unknown',
          coverUrl: song['imageUrl'] ?? '',
        )];
        _currentIndex = 0;
      }

      _currentImageUrl = _playlist[_currentIndex].coverUrl;

      if (song['audioUrl'] != null) {
        await _audioPlayer.setUrl(song['audioUrl']!);
        await _audioPlayer.play();
      }
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  // Play a playlist starting at specific index
  Future<void> playPlaylist(List<Track> playlist, int startIndex) async {
    try {
      _playlist = playlist;
      _currentIndex = startIndex;
      await _playTrack(_playlist[_currentIndex]);
    } catch (e) {
      print("Error playing playlist: $e");
    }
  }

  Future<void> _playTrack(Track track) async {
    try {
      _currentImageUrl = track.coverUrl;
      final audioUrl = await YouTubeMusicService.getAudioUrl(track.id);
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      print("Error playing track: $e");
    }
  }

  // Playback controls
  Future<void> nextSong() async {
    if (hasNext) {
      _currentIndex++;
      await _playTrack(_playlist[_currentIndex]);
    }
  }

  Future<void> previousSong() async {
    if (hasPrevious) {
      _currentIndex--;
      await _playTrack(_playlist[_currentIndex]);
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    notifyListeners();
  }

  Future<void> play() async => await _audioPlayer.play();
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> seek(Duration position) async => await _audioPlayer.seek(position);

  // Helper for formatting duration
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
