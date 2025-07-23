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
} 