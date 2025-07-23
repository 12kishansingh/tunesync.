import 'package:tunesync/model/friend_request.dart';
import 'package:tunesync/model/user.dart';

class FriendService {
  // Singleton pattern
  static final FriendService _instance = FriendService._internal();
  factory FriendService() => _instance;
  FriendService._internal();

  final List<FriendRequest> _sentRequests = [];
  final List<FriendRequest> _receivedRequests = [];
  final List<User> _friends = [];

  // For demo: current user
  final User currentUser = User(id: 'me', name: 'You', email: 'you@example.com', avatar: '😊');

  List<FriendRequest> get sentRequests => List.unmodifiable(_sentRequests);
  List<FriendRequest> get receivedRequests => List.unmodifiable(_receivedRequests);
  List<User> get friends => List.unmodifiable(_friends);

  void sendRequest(User toUser) {
    final request = FriendRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: currentUser,
      receiver: toUser,
      timestamp: DateTime.now(),
    );
    _sentRequests.add(request);
  }

  void receiveRequest(FriendRequest request) {
    _receivedRequests.add(request);
  }

  void acceptRequest(FriendRequest request) {
    _receivedRequests.removeWhere((r) => r.id == request.id);
    _friends.add(request.sender);
  }

  void declineRequest(FriendRequest request) {
    _receivedRequests.removeWhere((r) => r.id == request.id);
  }

  void removeFriend(User user) {
    _friends.removeWhere((f) => f.id == user.id);
  }

  void clearAll() {
    _sentRequests.clear();
    _receivedRequests.clear();
    _friends.clear();
  }
} 