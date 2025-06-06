import 'package:flutter/material.dart';
import 'package:tunesync/pages/Home/playlist_detail.dart';

class HomePage1 extends StatelessWidget {
  const HomePage1({super.key});

  final List<Map<String, String>> featuredPlaylists = const [
    {
      'title': 'New Music Friday',
      'imageUrl':
          'https://i.scdn.co/image/ab67706f000000024f0e29c49e86d1a8bb5e3b0b',
      'subtitle': 'Fresh tracks updated weekly.'
    },
    {
      'title': 'Release Radar',
      'imageUrl':
          'https://i.scdn.co/image/ab67706f00000002c58a95a92a92b769ad7f42cf',
      'subtitle': 'New music from artists you follow.'
    },
    {
      'title': 'New in Dance',
      'imageUrl':
          'https://i.scdn.co/image/ab67706f000000028c1a2333042c93b5cbd27555',
      'subtitle': 'Get your feet moving!'
    },
    {
      'title': 'Latest Love',
      'imageUrl':
          'https://i.scdn.co/image/ab67706f00000002f48ff6a4451ac1891f78e1e0',
      'subtitle': 'Romantic hits in Tamil.'
    },
    {
      'title': 'Rising Stars',
      'imageUrl':
          'https://i.scdn.co/image/ab67706f00000002efc7010508b6a75e53c6a25d',
      'subtitle': 'Upcoming artists you’ll love.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🎧 Featured Playlists",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: featuredPlaylists
                  .map((playlist) => _buildCard(
                        context,
                        playlist['title']!,
                        playlist['imageUrl']!,
                        playlist['subtitle']!,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text("🎤 Browse Artists",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                6,
                (index) => _buildCircleCard("Artist ${index + 1}"),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("🎶 Browse Genres",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              8,
              (index) => _buildGenreChip("Genre ${index + 1}"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, String imageUrl, String subtitle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(playlistName: title),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey, width: 160, height: 160),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleCard(String name) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.teal.shade200,
            child: Text(name[0], style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(name,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.teal.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
