import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:marquee/marquee.dart';

class FullScreenPlayer extends StatefulWidget {
  const FullScreenPlayer({super.key});

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final isActive = audioService.currentTitle != null;
        final title = audioService.currentTitle ?? 'Unknown Song';
        final artist = audioService.currentArtist ?? 'Unknown Artist';

        if (!isActive) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(179, 98, 95, 95),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon:
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'NOW PLAYING',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color.fromARGB(179, 98, 95, 95),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'NOW PLAYING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          body: Padding(
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 300,
                            height: 300,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_note,
                                color: Colors.white, size: 100),
                          ),
                        )
                      : Container(
                          width: 300,
                          height: 300,
                          color: Colors.grey[800],
                          child: const Icon(Icons.music_note,
                              color: Colors.white, size: 100),
                        ),
                ),
                const SizedBox(height: 40),
                // Song Title with Marquee Effect
                SizedBox(
                  height: 30,
                  child: Marquee(
                    text: title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    velocity: 30.0,
                    blankSpace: 50.0,
                    pauseAfterRound: const Duration(seconds: 1),
                    startPadding: 10.0,
                    fadingEdgeStartFraction: 0.1,
                    fadingEdgeEndFraction: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                // Artist Name
                Text(
                  artist,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 40),
                // Progress Bar with StreamBuilder
                StreamBuilder<Duration>(
                  stream: audioService.positionStream,
                  builder: (context, positionSnapshot) {
                    return StreamBuilder<Duration?>(
                      stream: audioService.durationStream,
                      builder: (context, durationSnapshot) {
                        final position = positionSnapshot.data ?? Duration.zero;
                        final duration = durationSnapshot.data ?? Duration.zero;

                        return Column(
                          children: [
                            Slider(
                              activeColor: Colors.white,
                              inactiveColor: Colors.grey[600],
                              value: duration.inSeconds > 0
                                  ? position.inSeconds.toDouble()
                                  : 0.0,
                              min: 0.0,
                              max: duration.inSeconds.toDouble() > 0
                                  ? duration.inSeconds.toDouble()
                                  : 1.0,
                              onChanged: (value) {
                                audioService
                                    .seek(Duration(seconds: value.toInt()));
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    audioService.formatDuration(position),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                  ),
                                  Text(
                                    audioService.formatDuration(duration),
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle Button
                    IconButton(
                      onPressed: audioService.toggleShuffle,
                      icon: Icon(
                        Icons.shuffle,
                        color: audioService.shuffleModeEnabled
                            ? Colors.teal
                            : Colors.white,
                        size: 40,
                      ),
                    ),
                    // Previous Button
                    IconButton(
                      onPressed: audioService.hasPrevious
                          ? audioService.previousSong
                          : null,
                      icon: Icon(
                        Icons.skip_previous,
                        color: audioService.hasPrevious
                            ? Colors.white
                            : Colors.grey[600],
                        size: 40,
                      ),
                    ),
                    // Play/Pause Button
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: audioService.togglePlayPause,
                        icon: Icon(
                          audioService.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ),
                    // Next Button
                    IconButton(
                      onPressed:
                          audioService.hasNext ? audioService.nextSong : null,
                      icon: Icon(
                        Icons.skip_next,
                        color: audioService.hasNext
                            ? Colors.white
                            : Colors.grey[600],
                        size: 40,
                      ),
                    ),
                    // Loop Button
                    IconButton(
                      onPressed: audioService.toggleLoop,
                      icon: Icon(
                        Icons.loop,
                        color: audioService.loopOneEnabled
                            ? Colors.teal
                            : Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
