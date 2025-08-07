import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:tunesync/model/friend_request.dart';
import 'package:tunesync/model/user.dart';

class FriendService {
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = fb_auth.FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Test method to verify Firestore access
  Future<bool> testFirestoreAccess() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('Test failed: No authenticated user');
        return false;
      }
      
      print('Testing Firestore access for user: ${currentUser.uid}');
      
      // Try to read a single document to test permissions
      final testDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      print('Successfully read user document: ${testDoc.exists}');
      
      // Try to read the users collection
      final usersSnapshot = await _firestore.collection('users').limit(1).get();
      print('Successfully read users collection: ${usersSnapshot.docs.length} documents');
      
      return true;
    } catch (e) {
      print('Firestore access test failed: $e');
      return false;
    }
  }

  // Send a friend request
  Future<void> sendRequest(User toUser) async {
    final requestDoc = _firestore.collection('friend_requests').doc();
    await requestDoc.set({
      'id': requestDoc.id,
      'senderId': currentUserId,
      'receiverId': toUser.id,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // Accept a friend request
  Future<void> acceptRequest(FriendRequest request) async {
    final requestRef = _firestore.collection('friend_requests').doc(request.id);
    await requestRef.update({'status': 'accepted'});
    // Add each user to the other's friends subcollection
    await _firestore.collection('users').doc(currentUserId).collection('friends').doc(request.sender.id).set({
      'id': request.sender.id,
      'name': request.sender.name,
      'email': request.sender.email,
      'avatar': request.sender.avatar,
    });
    await _firestore.collection('users').doc(request.sender.id).collection('friends').doc(currentUserId).set({
      'id': currentUserId,
      // You may want to fetch the current user's info here
    });
  }

  // Decline a friend request
  Future<void> declineRequest(FriendRequest request) async {
    final requestRef = _firestore.collection('friend_requests').doc(request.id);
    await requestRef.update({'status': 'declined'});
  }

  // Get sent friend requests
  Stream<List<FriendRequest>> getSentRequests() {
    return _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FriendRequest(
              id: doc['id'],
              sender: User(id: doc['senderId'], name: '', email: '', avatar: ''),
              receiver: User(id: doc['receiverId'], name: '', email: '', avatar: ''),
              timestamp: (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            )).toList());
  }

  // Get received friend requests
  Stream<List<FriendRequest>> getReceivedRequests() {
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FriendRequest(
              id: doc['id'],
              sender: User(id: doc['senderId'], name: '', email: '', avatar: ''),
              receiver: User(id: doc['receiverId'], name: '', email: '', avatar: ''),
              timestamp: (doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            )).toList());
  }

  // Get friends list
  Stream<List<User>> getFriends() {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => User(
              id: doc['id'],
              name: doc['name'] ?? '',
              email: doc['email'] ?? '',
              avatar: doc['avatar'] ?? '',
            )).toList());
  }

  // Search users by name or email (case-insensitive, excludes current user)
  Future<List<User>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    
    // Check authentication status first
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }
    
    // Check if user token is valid
    try {
      await currentUser.getIdToken(true); // Force refresh token
    } catch (e) {
      throw Exception('Authentication token expired. Please sign in again.');
    }
    
    try {
      final lowerQuery = query.toLowerCase();
      print('Searching for users with query: $query');
      print('Current user ID: ${currentUser.uid}');
      
      final usersSnapshot = await _firestore.collection('users').get();
      print('Found ${usersSnapshot.docs.length} total users in database');
      
      final results = usersSnapshot.docs
          .map((doc) => User(
                id: doc.id, // Use document ID instead of 'id' field
                name: doc.data()['name'] ?? '',
                email: doc.data()['email'] ?? '',
                avatar: doc.data()['avatar'] ?? '',
                isOnline: doc.data()['isOnline'] ?? false,
              ))
          .where((user) =>
              user.id != currentUserId &&
              (user.name.toLowerCase().contains(lowerQuery) ||
               user.email.toLowerCase().contains(lowerQuery)))
          .toList();
      
      print('Found ${results.length} matching users');
      return results;
    } catch (e) {
      print('Error in searchUsers: $e');
      // Provide more specific error messages
      if (e.toString().contains('permission-denied')) {
        throw Exception('Permission denied: Unable to search users. Please check your authentication status.');
      } else if (e.toString().contains('unavailable')) {
        throw Exception('Network error: Unable to connect to the server. Please check your internet connection.');
      } else {
        throw Exception('Search failed: ${e.toString()}');
      }
    }
  }
} 