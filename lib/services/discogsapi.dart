import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscogsAPI {
  static const String baseUrl = 'https://api.discogs.com';
  static const String consumerKey = 'FnKdhVcWvNVrOsTbjLGU';
  static const String consumerSecret = 'fpnIISOgDWdnwFXZOhdaqnMczSrezimM';

  // Existing methods
  static Future<Map<String, dynamic>?> searchGenre(String genre) async {
    final url = Uri.parse(
        '$baseUrl/database/search?genre=$genre&type=release&key=$consumerKey&secret=$consumerSecret');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error fetching genre: ${response.statusCode}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> searchArtist(String query) async {
    final url = Uri.parse(
      '$baseUrl/database/search?q=$query&type=artist&key=$consumerKey&secret=$consumerSecret',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed artist search: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error searching artist: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getArtistReleases(int artistId) async {
    final url = Uri.parse(
      '$baseUrl/artists/$artistId/releases?key=$consumerKey&secret=$consumerSecret',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['releases'];
      } else {
        print('Failed to get releases: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting artist releases: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> searchByGenre(String genre) async {
    final url = Uri.parse(
      '$baseUrl/database/search?genre=$genre&type=release&key=$consumerKey&secret=$consumerSecret',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'];
      } else {
        print('Failed genre search: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error searching by genre: $e');
      return null;
    }
  }

  // New track search method with error handling
  static Future<Map<String, dynamic>?> searchTrack(String title) async {
    try {
      final url = Uri.parse(
        '$baseUrl/database/search?track=$title&type=release&key=$consumerKey&secret=$consumerSecret',
      );
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed track search: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error searching track: $e');
      return null;
    }
  }
}
