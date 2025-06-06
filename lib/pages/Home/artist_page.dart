import 'package:flutter/material.dart';
import 'package:tunesync/services/discogsapi.dart';
import 'package:tunesync/pages/Home/artist_releases_page.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _results = [];

  void _search() async {
    final data = await DiscogsAPI.searchArtist(_controller.text);
    if (data != null && data['results'] != null) {
      setState(() {
        _results = data['results']
            .where((r) => r['type'] == 'artist' && r.containsKey('id'))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Search Artist',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _search,
              ),
            ],
          ),
        ),
        Expanded(
          child: _results.isEmpty
              ? const Center(child: Text('No results'))
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final artist = _results[index];
                    return ListTile(
                      title: Text(artist['title'] ?? 'Unknown Artist'),
                      subtitle: Text('ID: ${artist['id']}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtistReleasesPage(
                              artistId: artist['id'],
                              artistName: artist['title'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
