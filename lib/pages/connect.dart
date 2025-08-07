import 'package:flutter/material.dart';
import 'package:tunesync/model/friend_request.dart';
import 'package:tunesync/model/user.dart';
import 'package:tunesync/services/friend_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:async';

// The ConnectPage widget lets users find, send, and respond to friend requests.
class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final FriendService _friendService = FriendService();
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  List<User> _suggestedUsers = [
    User(id: '1', name: 'Alice Johnson', email: 'alice@example.com', avatar: '🦸‍♀️', isOnline: true),
    User(id: '2', name: 'Bob Smith', email: 'bob@example.com', avatar: '👨‍💻', isOnline: false),
    User(id: '3', name: 'Carol Davis', email: 'carol@example.com', avatar: '👩‍🎨', isOnline: true),
    User(id: '4', name: 'David Wilson', email: 'david@example.com', avatar: '🧑‍🚀', isOnline: false),
  ];

  List<User> _searchResults = [];
  bool _isSearching = false;
  String _searchText = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      print('User is authenticated: ${currentUser.uid}');
      print('User email: ${currentUser.email}');
    } else {
      print('User is NOT authenticated');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendFriendRequest(User user) async {
    await _friendService.sendRequest(user);
    setState(() {
      _suggestedUsers.remove(user);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request sent to ${user.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _acceptFriendRequest(FriendRequest request) async {
    await _friendService.acceptRequest(request);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are now friends with ${request.sender.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _rejectFriendRequest(FriendRequest request) async {
    await _friendService.declineRequest(request);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Friend request from ${request.sender.name} rejected'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Record start time for minimum loading duration
    final startTime = DateTime.now();

    try {
      final results = await _friendService.searchUsers(query);
      
      // Ensure minimum loading time of 300ms for better UX
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed.inMilliseconds < 300) {
        await Future.delayed(Duration(milliseconds: 300 - elapsed.inMilliseconds));
      }
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                  StreamBuilder<List<FriendRequest>>(
                    stream: _friendService.getSentRequests(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Tab(text: 'Sent ($count)', icon: Icon(Icons.send, size: 16));
                    },
                  ),
                  StreamBuilder<List<FriendRequest>>(
                    stream: _friendService.getReceivedRequests(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Tab(text: 'Received ($count)', icon: Icon(Icons.inbox, size: 16));
                    },
                  ),
                  StreamBuilder<List<User>>(
                    stream: _friendService.getFriends(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Tab(text: 'Friends ($count)', icon: Icon(Icons.people, size: 16));
                    },
                  ),
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
        // Authentication status indicator
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _auth.currentUser != null ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _auth.currentUser != null ? Colors.green : Colors.red,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _auth.currentUser != null ? Icons.check_circle : Icons.error,
                color: _auth.currentUser != null ? Colors.green : Colors.red,
                size: 16,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _auth.currentUser != null 
                    ? 'Authenticated: ${_auth.currentUser!.email}'
                    : 'Not authenticated',
                  style: TextStyle(
                    fontSize: 12,
                    color: _auth.currentUser != null ? Colors.green : Colors.red,
                  ),
                ),
              ),
              if (_auth.currentUser != null)
                TextButton(
                  onPressed: () async {
                    final success = await _friendService.testFirestoreAccess();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Firestore access test passed!' : 'Firestore access test failed!'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                  child: Text('Test Access', style: TextStyle(fontSize: 10)),
                ),
            ],
          ),
        ),
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
              
              // Cancel previous timer
              _debounceTimer?.cancel();
              
              // Set a new timer for debouncing
              _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                _performSearch(value);
              });
            },
          ),
        ),
        Expanded(
          child: _isSearching
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Searching for users...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : _searchText.isEmpty
                  ? Center(child: Text('Type to search for users', style: TextStyle(color: Colors.grey)))
                  : _searchResults.isEmpty
                      ? Center(child: Text('No users found', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return _buildUserCard(_searchResults[index], true);
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildSentRequestsTab() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendService.getSentRequests(),
      builder: (context, snapshot) {
        final sentRequests = snapshot.data ?? [];
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
      },
    );
  }

  Widget _buildReceivedRequestsTab() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendService.getReceivedRequests(),
      builder: (context, snapshot) {
        final receivedRequests = snapshot.data ?? [];
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
      },
    );
  }

  Widget _buildFriendsTab() {
    return StreamBuilder<List<User>>(
      stream: _friendService.getFriends(),
      builder: (context, snapshot) {
        final friends = snapshot.data ?? [];
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
                // Remove friend logic can be added here if needed
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserCard(User user, bool canSendRequest) {
    // For demo, you may want to check Firestore for sent requests/friends
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
        trailing: canSendRequest
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
          ],
        ),
        title: Text(user.id, style: TextStyle(fontWeight: FontWeight.bold)),
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

