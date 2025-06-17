import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Current song info
  String? _currentTitle;
  String? _currentArtist;
  String? _currentImageUrl;
  
  // Playback state
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  
  // Playlist management
  List<Map<String, String>> _playlist = [];
  int _currentIndex = 0;

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  String? get currentTitle => _currentTitle;
  String? get currentArtist => _currentArtist;
  String? get currentImageUrl => _currentImageUrl;
  List<Map<String, String>> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _playlist.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  AudioPlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState != null) {
        _currentIndex = sequenceState.currentIndex!;
        _updateCurrentSongInfo();
        notifyListeners();
      }
    });
  }

  void _updateCurrentSongInfo() {
    if (_playlist.isNotEmpty && _currentIndex < _playlist.length) {
      final currentSong = _playlist[_currentIndex];
      _currentTitle = currentSong['title'];
      _currentArtist = currentSong['artist'];
      _currentImageUrl = currentSong['imageUrl'];
    }
  }

  // Play single track with direct URL
  Future<void> playDirect(String url, {String? title, String? artist, String? imageUrl}) async {
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
      _currentTitle = title;
      _currentArtist = artist;
      _currentImageUrl = imageUrl;
      notifyListeners();
    } catch (e) {
      print('Error playing direct: $e');
    }
  }

  // Play song with playlist context
  Future<void> playSong(Map<String, String> song, {List<Map<String, String>>? playlist, int index = 0}) async {
    try {
      if (playlist != null) {
        _playlist = playlist;
        _currentIndex = index;
      } else {
        _playlist = [song];
        _currentIndex = 0;
      }

      _updateCurrentSongInfo();

      if (song['audioUrl'] != null) {
        await _audioPlayer.setUrl(song['audioUrl']!);
        await _audioPlayer.play();
      }
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  // Control methods
  Future<void> togglePlayPause() async {
    _isPlaying ? await pause() : await play();
  }

  Future<void> play() async => await _audioPlayer.play();
  Future<void> pause() async => await _audioPlayer.pause();
  Future<void> seek(Duration position) async => await _audioPlayer.seek(position);

  Future<void> nextSong() async {
    if (hasNext) {
      _currentIndex++;
      await playSong(_playlist[_currentIndex]);
    }
  }

  Future<void> previousSong() async {
    if (hasPrevious) {
      _currentIndex--;
      await playSong(_playlist[_currentIndex]);
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTitle = null;
    _currentArtist = null;
    _currentImageUrl = null;
    notifyListeners();
  }

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
