import 'user.dart';
class FriendRequest {
  final String id;
  final User sender;
  final User receiver;
  final DateTime timestamp;
  final String status; // Can be 'pending', 'accepted', 'rejected'

  FriendRequest({
    required this.id,
    required this.sender,
    required this.receiver,
    required this.timestamp,
    this.status = 'pending',
  });
}
