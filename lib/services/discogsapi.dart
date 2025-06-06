import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscogsAPI {
  static const String baseUrl = 'https://api.discogs.com';
  static const String consumerKey = 'FnKdhVcWvNVrOsTbjLGU';
  static const String consumerSecret = 'fpnIISOgDWdnwFXZOhdaqnMczSrezimM';

  static Future<Map<String, dynamic>?> searchArtist(String query) async {
    final url = Uri.parse(
        '$baseUrl/database/search?q=$query&type=artist&key=$consumerKey&secret=$consumerSecret');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error: ${response.statusCode}');
      return null;
    }
  }
}
