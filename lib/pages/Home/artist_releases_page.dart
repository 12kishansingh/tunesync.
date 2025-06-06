import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/discogsapi.dart';

class ArtistReleasesPage extends StatefulWidget {
  final int artistId;
  final String artistName;

  const ArtistReleasesPage({super.key, required this.artistId, required this.artistName});

  @override
  State<ArtistReleasesPage> createState() => _ArtistReleasesPageState();
}

class _ArtistReleasesPageState extends State<ArtistReleasesPage> {
  List _releases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtistReleases();
  }

  Future<void> _fetchArtistReleases() async {
    final url = Uri.parse(
      'https://api.discogs.com/artists/${widget.artistId}/releases?per_page=20&page=1&key=${DiscogsAPI.consumerKey}&secret=${DiscogsAPI.consumerSecret}',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _releases = data['releases'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.artistName} Releases")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _releases.length,
              itemBuilder: (context, index) {
                final release = _releases[index];
                return ListTile(
                  title: Text(release['title'] ?? 'No title'),
                  subtitle: Text("Type: ${release['type']}, Year: ${release['year'] ?? 'N/A'}"),
                );
              },
            ),
    );
  }
}
