import 'package:flutter/material.dart';
import 'package:tunesync/model/friend_request.dart';
import 'package:tunesync/model/user.dart';
import 'package:tunesync/services/friend_service.dart';
// The ConnectPage widget lets users find, send, and respond to friend requests.
class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final FriendService _friendService = FriendService();

  List<User> _suggestedUsers = [
    User(id: '1', name: 'Alice Johnson', email: 'alice@example.com', avatar: '🦸‍♀️', isOnline: true),
    User(id: '2', name: 'Bob Smith', email: 'bob@example.com', avatar: '👨‍💻', isOnline: false),
    User(id: '3', name: 'Carol Davis', email: 'carol@example.com', avatar: '👩‍🎨', isOnline: true),
    User(id: '4', name: 'David Wilson', email: 'david@example.com', avatar: '🧑‍🚀', isOnline: false),
  ];

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _sendFriendRequest(User user) {
    setState(() {
      _friendService.sendRequest(user);
      _suggestedUsers.remove(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${user.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _acceptFriendRequest(FriendRequest request) {
    setState(() {
      _friendService.acceptRequest(request);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are now friends with ${request.sender.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectFriendRequest(FriendRequest request) {
    setState(() {
      _friendService.declineRequest(request);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request from ${request.sender.name} rejected'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _suggestedUsers.where((user) {
      final name = user.name.toLowerCase();
      final email = user.email.toLowerCase();
      return name.contains(_searchText.toLowerCase()) ||
          email.contains(_searchText.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(30), right: Radius.circular(30)),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.09),
                ),
                labelPadding: EdgeInsets.symmetric(horizontal: 2),
                tabs: [
                  Tab(text: 'Discover', icon: Icon(Icons.explore, size: 16)),
                  Tab(text: 'Sent (${_friendService.sentRequests.length})', icon: Icon(Icons.send, size: 16)),
                  Tab(text: 'Received (${_friendService.receivedRequests.length})', icon: Icon(Icons.inbox, size: 16)),
                  Tab(text: 'Friends (${_friendService.friends.length})', icon: Icon(Icons.people, size: 16)),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDiscoverTab(filteredUsers),
              _buildSentRequestsTab(),
              _buildReceivedRequestsTab(),
              _buildFriendsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoverTab(List<User> users) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for friends...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Text('No users found', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(users[index], true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSentRequestsTab() {
    final sentRequests = _friendService.sentRequests;
    if (sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No sent requests', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: sentRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(sentRequests[index], false);
      },
    );
  }

  Widget _buildReceivedRequestsTab() {
    final receivedRequests = _friendService.receivedRequests;
    if (receivedRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No received requests', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: receivedRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(receivedRequests[index], true);
      },
    );
  }

  Widget _buildFriendsTab() {
    final friends = _friendService.friends;
    if (friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No friends yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final user = friends[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              child: Text(user.avatar, style: TextStyle(fontSize: 20)),
            ),
            title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(user.email),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              tooltip: 'Remove Friend',
              onPressed: () {
                setState(() {
                  _friendService.removeFriend(user);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${user.name} from friends'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(User user, bool canSendRequest) {
    final alreadySent = _friendService.sentRequests.any((r) => r.receiver.id == user.id);
    final alreadyFriend = _friendService.friends.any((f) => f.id == user.id);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(user.avatar, style: TextStyle(fontSize: 20)),
            ),
            if (user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(
              user.isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                color: user.isOnline ? Colors.green : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: alreadyFriend
            ? Text('Friend', style: TextStyle(color: Colors.green))
            : alreadySent
                ? Text('Request Sent', style: TextStyle(color: Colors.orange))
                : canSendRequest
                    ? ElevatedButton.icon(
                        onPressed: () => _sendFriendRequest(user),
                        icon: Icon(Icons.person_add, size: 16),
                        label: Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      )
                    : null,
        isThreeLine: true,
      ),
    );
  }

  Widget _buildRequestCard(FriendRequest request, bool isReceived) {
    final user = isReceived ? request.sender : request.receiver;
    final timeAgo = _timeAgo(request.timestamp);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              child: Text(user.avatar, style: TextStyle(fontSize: 20)),
            ),
            if (user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(timeAgo),
        trailing: isReceived
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _acceptFriendRequest(request),
                    icon: Icon(Icons.check, color: Colors.green),
                    tooltip: 'Accept',
                  ),
                  IconButton(
                    onPressed: () => _rejectFriendRequest(request),
                    icon: Icon(Icons.close, color: Colors.red),
                    tooltip: 'Reject',
                  ),
                ],
              )
            : Icon(Icons.access_time, color: Colors.orange),
      ),
    );
  }

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

