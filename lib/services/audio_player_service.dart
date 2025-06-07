import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioPlayerService with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentTrackTitle;
  String? _currentArtist;
  String? _coverImageUrl;

  AudioPlayer get player => _audioPlayer;

  bool get isPlaying => _isPlaying;
  String? get currentTrackTitle => _currentTrackTitle;
  String? get currentArtist => _currentArtist;
  String? get coverImageUrl => _coverImageUrl;

  AudioPlayerService() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> playTrack({
    required String audioUrl,
    required String title,
    required String artist,
    String? coverImage,
  }) async {
    try {
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
      _currentTrackTitle = title;
      _currentArtist = artist;
      _coverImageUrl = coverImage;
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      print("Error playing track: $e");
    }
  }

  Future<void> togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> dispose() async {
    _audioPlayer.dispose();
    super.dispose();
  }
}