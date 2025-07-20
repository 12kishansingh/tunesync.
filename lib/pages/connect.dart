import 'package:flutter/material.dart';
import 'package:tunesync/model/friend_request.dart';
import 'package:tunesync/model/user.dart';
// The ConnectPage widget lets users find, send, and respond to friend requests.
class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Replace this with data from your backend or database.
  // For now, using mock/sample data for illustration.
  List<User> _suggestedUsers = [
    User(id: '1', name: 'Alice Johnson', email: 'alice@example.com', avatar: '🦸‍♀️', isOnline: true),
    User(id: '2', name: 'Bob Smith', email: 'bob@example.com', avatar: '👨‍💻', isOnline: false),
    User(id: '3', name: 'Carol Davis', email: 'carol@example.com', avatar: '👩‍🎨', isOnline: true),
    User(id: '4', name: 'David Wilson', email: 'david@example.com', avatar: '🧑‍🚀', isOnline: false),
  ];

  List<FriendRequest> _sentRequests = [];
  List<FriendRequest> _receivedRequests = [
    FriendRequest(
      id: '1',
      sender: User(id: '5', name: 'Emma Brown', email: 'emma@example.com', avatar: '👩‍🔬', isOnline: true),
      receiver: User(id: 'me', name: 'You', email: 'you@example.com', avatar: '😊'),
      timestamp: DateTime.now().subtract(Duration(hours: 2)),
    ),
  ];

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _sendFriendRequest(User user) {
    setState(() {
      _sentRequests.add(FriendRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: User(id: 'me', name: 'You', email: 'you@example.com', avatar: '😊'),
        receiver: user,
        timestamp: DateTime.now(),
      ));
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
      _receivedRequests.remove(request);
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
      _receivedRequests.remove(request);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Connect'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Discover', icon: Icon(Icons.explore)),
            Tab(text: 'Sent (${_sentRequests.length})', icon: Icon(Icons.send)),
            Tab(text: 'Received (${_receivedRequests.length})', icon: Icon(Icons.inbox)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(filteredUsers),
          _buildSentRequestsTab(),
          _buildReceivedRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab(List<User> users) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for friends...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
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
    if (_sentRequests.isEmpty) {
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
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(_sentRequests[index], false);
      },
    );
  }

  Widget _buildReceivedRequestsTab() {
    if (_receivedRequests.isEmpty) {
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
      itemCount: _receivedRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(_receivedRequests[index], true);
      },
    );
  }

  Widget _buildUserCard(User user, bool canSendRequest) {
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
        trailing: canSendRequest
            ? ElevatedButton.icon(
                onPressed: () => _sendFriendRequest(user),
                icon: Icon(Icons.person_add, size: 16),
                label: Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            : Text('Request Sent', style: TextStyle(color: Colors.orange)),
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

