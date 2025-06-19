import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/audio_player.dart';

class FullScreenPlayer extends StatelessWidget {
  const FullScreenPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(179, 98, 95, 95),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PLAYLIST',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<AudioPlayerService>(
        builder: (context, audioService, child) {
          final isActive = audioService.currentTitle != null;
          if (!isActive) {
            // Show "No song playing" message
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.music_note, size: 80, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'No song is playing',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select a song to play',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            );
          }
          // Show song details and controls
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Spacer(),
                // Album Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: audioService.currentImageUrl != null
                      ? Image.network(
                          audioService.currentImageUrl!,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note, color: Colors.white, size: 100),
                          ),
                        )
                      : Container(
                          width: 300,
                          height: 300,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note, color: Colors.white, size: 100),
                        ),
                ),
                const SizedBox(height: 40),
                // Song Title and Artist
                Text(
                  audioService.currentTitle ?? 'Unknown Song',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  audioService.currentArtist ?? 'Unknown Artist',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Progress Bar
                Column(
                  children: [
                    Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey[600],
                      value: audioService.duration.inSeconds > 0
                          ? audioService.position.inSeconds.toDouble()
                          : 0.0,
                      min: 0.0,
                      max: audioService.duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        audioService.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            audioService.formatDuration(audioService.position),
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                          Text(
                            audioService.formatDuration(audioService.duration),
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: audioService.hasPrevious ? audioService.previousSong : null,
                      icon: Icon(
                        Icons.skip_previous,
                        color: audioService.hasPrevious ? Colors.white : Colors.grey[600],
                        size: 40,
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: audioService.togglePlayPause,
                        icon: Icon(
                          audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: audioService.hasNext ? audioService.nextSong : null,
                      icon: Icon(
                        Icons.skip_next,
                        color: audioService.hasNext ? Colors.white : Colors.grey[600],
                        size: 40,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }
}
