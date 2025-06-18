import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/services/audio_player.dart'; // Correct import
import 'package:tunesync/pages/full_screen_page.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final isActive = audioService.currentTitle != null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FullScreenPlayer()),
              );
            },
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border(
                  top: BorderSide(
                    color: Colors.black.withOpacity(0.12),
                    width: 1.5,
                  ),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: isActive && audioService.currentImageUrl != null
                        ? Image.network(
                            audioService.currentImageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[600],
                              child: const Icon(Icons.music_note,
                                  color: Colors.white),
                            ),
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[600],
                            child: const Icon(Icons.music_note,
                                color: Colors.white),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isActive
                              ? audioService.currentTitle!
                              : 'No song playing',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isActive
                              ? audioService.currentArtist ?? ''
                              : 'Select a song to play',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: isActive ? audioService.togglePlayPause : null,
                    icon: Icon(
                      isActive
                          ? (audioService.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow)
                          : Icons.play_arrow,
                      color: Colors.black.withOpacity(isActive ? 1 : 0.5),
                      size: 28,
                    ),
                  ),
                  IconButton(
                    onPressed: isActive && audioService.hasNext
                        ? audioService.nextSong
                        : null,
                    icon: Icon(
                      Icons.skip_next,
                      color: isActive && audioService.hasNext
                          ? Colors.white
                          : Colors.grey[600],
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
