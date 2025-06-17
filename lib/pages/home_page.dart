import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tunesync/pages/Home/artist_page.dart';
import 'package:tunesync/pages/Home/h1.dart';
import 'package:tunesync/pages/profle_info.dart';
import 'package:tunesync/pages/search_and_play.dart';

import 'package:tunesync/widgets/mini_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  static List<Widget> _pages() => const [
        HomePage1(),
        Center(child: Text("Connect Page")),
        Center(child: Text("Library Page")),
        ArtistsPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TuneSync",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Tooltip(
            message: 'Search',
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Navigate to SearchAndPlayPage instead of showing SnackBar
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchAndPlayPage()),
                );
              },
            ),
          ),
          Tooltip(
            message: 'Profile info',
            child: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=>const ProfilePage()),
                );
              },
            ),
          ),
          Tooltip(
            message: 'Sign Out',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: signUserOut,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(child: _pages()[_selectedIndex]),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
        backgroundColor: const Color.fromARGB(255, 0, 194, 168),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: 'Connect',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Artists',
          ),
        ],
      ),
    );
  }
}
