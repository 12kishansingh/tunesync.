import 'package:flutter/material.dart';

class HomePage1 extends StatelessWidget {
  const HomePage1({super.key});

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
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(
                5,
                (index) => _buildCard("Playlist ${index + 1}"),
              ),
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

  Widget _buildCard(String title) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.purple.shade100,
      ),
      child: Center(
        child: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600)),
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
          Text(name, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
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
