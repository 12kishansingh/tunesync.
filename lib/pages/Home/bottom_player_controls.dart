import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/audio_player.dart';

class BottomPlayerControls extends StatelessWidget {
  const BottomPlayerControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioPlayerService>(context);
    final isPlaying = audioService.isPlaying;
    final currentTrack = audioService.currentTitle; // Updated
    final artist = audioService.currentArtist;
    final coverImage = audioService.currentImageUrl; // Updated

    if (currentTrack == null) return const SizedBox();

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: const Border(top: BorderSide(color: Colors.white24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Album Art
            coverImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      coverImage,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
            const Gap(16),

            // Track Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTrack,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const Gap(4),
                  Text(
                    artist ?? 'Unknown Artist',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Gap(16),

            // Player Controls
            StreamBuilder<Duration>(
              stream: audioService.audioPlayer.positionStream, // Updated
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return StreamBuilder<Duration?>(
                  stream: audioService.audioPlayer.durationStream, // Updated
                  builder: (context, durationSnapshot) {
                    final duration = durationSnapshot.data ?? Duration.zero;
                    return Row(
                      children: [
                        // Progress Bar
                        SizedBox(
                          width: 100,
                          child: Slider(
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            value: position.inSeconds.clamp(0, duration.inSeconds).toDouble(),
                            onChanged: (value) {
                              audioService.seek(Duration(seconds: value.toInt()));
                            },
                            activeColor: Colors.teal,
                            inactiveColor: Colors.grey[700],
                          ),
                        ),
                        const Gap(8),

                        // Current Time
                        Text(
                          _formatDuration(position),
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const Gap(8),

                        // Play/Pause Button
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: audioService.togglePlayPause, // Updated
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
