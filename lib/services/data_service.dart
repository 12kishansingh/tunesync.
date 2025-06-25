// lib/services/data_service.dart
import 'package:tunesync/DB/albums.db.dart';
import 'package:tunesync/DB/playlists.db.dart';

class DataService {
  static List<Map<String, dynamic>> getFeaturedPlaylists() {
    return playlistsDB;
  }

  static List<Map<String, dynamic>> getFeaturedAlbums() {
    return albumsDB.cast<Map<String, dynamic>>();
  }
}
