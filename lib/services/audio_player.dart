import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tunesync/model/track.dart';
import 'package:tunesync/services/youtube_music_service.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Track> _playlist = [];
  int _currentIndex = -1;
  String? _currentImageUrl;
  final Random _random = Random();
  bool _loopOneEnabled = false;
  bool _shuffleModeEnabled = false;

  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<bool> get isPlayingStream => 
      _audioPlayer.playerStateStream.map((state) => state.playing).distinct();

  // Getters
  AudioPlayer get audioPlayer => _audioPlayer;
  String? get currentTitle => _currentIndex >= 0 ? _playlist[_currentIndex].title : null;
  String? get currentArtist => _currentIndex >= 0 ? _playlist[_currentIndex].artist : null;
  String? get currentImageUrl=> _currentImageUrl;
  bool get isPlaying => _audioPlayer.playing;
  bool get hasNext => _playlist.isNotEmpty;
  bool get hasPrevious => _playlist.isNotEmpty;
  bool get loopOneEnabled => _loopOneEnabled;
  bool get shuffleModeEnabled => _shuffleModeEnabled;

  AudioPlayerService() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopOneEnabled) {
          _replayCurrent();
        } else {
          nextSong();
        }
      }
      notifyListeners();
    });
  }

  // Toggle loop mode
  void toggleLoop() {
    _loopOneEnabled = !_loopOneEnabled;
    notifyListeners();
  }

  // Toggle shuffle mode
  void toggleShuffle() {
    _shuffleModeEnabled = !_shuffleModeEnabled;
    notifyListeners();
  }

  // Play single track
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

  // Play playlist
  Future<void> playPlaylist(List<Track> playlist, int startIndex) async {
    try {
      _playlist = playlist;
      _currentIndex = startIndex;
      await _playTrack(_playlist[_currentIndex]);
    } catch (e) {
      print("Error playing playlist:");
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

  Future<void> _replayCurrent() async {
    if (_currentIndex >= 0) {
      await _playTrack(_playlist[_currentIndex]);
    }
  }

  // Play next song
  Future<void> nextSong() async {
    if (_playlist.isEmpty) return;
    
    int newIndex;
    if (_shuffleModeEnabled) {
      // Shuffle mode: pick a random song
      do {
        newIndex = _random.nextInt(_playlist.length);
      } while (newIndex == _currentIndex && _playlist.length > 1);
    } else {
      // Sequential mode: play next in order
      newIndex = (_currentIndex + 1) % _playlist.length;
    }
    
    _currentIndex = newIndex;
    await _playTrack(_playlist[_currentIndex]);
  }

  // Play previous song
  Future<void> previousSong() async {
    if (_playlist.isEmpty) return;
    
    int newIndex;
    if (_shuffleModeEnabled) {
      // Shuffle mode: pick a random song
      do {
        newIndex = _random.nextInt(_playlist.length);
      } while (newIndex == _currentIndex && _playlist.length > 1);
    } else {
      // Sequential mode: play previous in order
      newIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
    }
    
    _currentIndex = newIndex;
    await _playTrack(_playlist[_currentIndex]);
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
