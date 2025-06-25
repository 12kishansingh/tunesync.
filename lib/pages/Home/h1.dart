import 'package:flutter/material.dart';
import 'package:tunesync/services/data_service.dart';
import 'package:tunesync/pages/Home/playlist_detail.dart';

class HomePage1 extends StatelessWidget {
  const HomePage1({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> featuredPlaylists =
        DataService.getFeaturedPlaylists();
    final List<Map<String, dynamic>> featuredAlbums =
        DataService.getFeaturedAlbums();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Playlists Section
          _buildSectionHeader("Playlists"),
          const SizedBox(height: 1),
          _buildHorizontalList(featuredPlaylists, context),
          const SizedBox(height: 1),

          // Featured Albums Section
          _buildSectionHeader("Albums"),
          const SizedBox(height: 1),
          _buildHorizontalList(featuredAlbums, context),
          const SizedBox(height: 1),

          // Browse Artists Section
          const Text(
            "Browse Artists",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) =>
                  _buildCircleCard("Artist ${index + 1}"),
            ),
          ),

          const SizedBox(height: 20),

          // Browse Genres Section
          const Text(
            "Browse Genres",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
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

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {/* Show all */},
          child:
              const Text("Show all", style: TextStyle(color: Colors.blueGrey)),
        ),
      ],
    );
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> items, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth = constraints.maxWidth * 0.42;
        return SizedBox(
          height: itemWidth + 19,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            padding: const EdgeInsets.only(right: 16),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _navigateToDetail(context, items[index]),
                child: Container(
                  width: itemWidth,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : 12,
                    right: index == items.length - 1 ? 0 : 0,
                  ),
                  child: _buildMusicCard(items[index], context),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMusicCard(Map<String, dynamic> item, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item['image'] ?? '',
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[800],
              height: 100,
              child: const Icon(Icons.music_note, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item['title'] ?? 'Untitled',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (item['subtitle'] != null)
          Text(
            item['subtitle']!,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  void _navigateToDetail(BuildContext context, Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(
          playlistName: item['title'] ?? 'Untitled',
          playlistSubtitle: item['subtitle'] ?? '',
          playlistImageUrl: item['image'] ?? '',
          genre: item['genre'] ?? 'pop',
          ytid: item['ytid'] ?? '',
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
            child: Text(name[0],
                style: const TextStyle(fontSize: 24, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
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
