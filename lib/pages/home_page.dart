import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/pages/Home/artist_page.dart';
import 'package:tunesync/pages/Home/h1.dart';
import 'package:tunesync/pages/login_or_register.dart';
import 'package:tunesync/pages/profle_info.dart';
import 'package:tunesync/pages/search_and_play.dart';
import 'package:tunesync/services/audio_player.dart';
import 'package:tunesync/widgets/mini_player.dart';
import 'package:tunesync/pages/connect.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _selectedIndex = 0;

  static List<Widget> _pages() =>  [
        HomePage1(),
        ConnectPage(), 
        Center(child: Text("Library Page")),
        ArtistsPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> signUserOut(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Stop and dispose the audio player
      final audioService = Provider.of<AudioPlayerService>(context, listen: false);
      await audioService.disposePlayer();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to login/register page and clear navigation stack
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginOrRegister()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign out failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TuneSync", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Tooltip(
            message: 'Search',
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchAndPlayPage()),
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
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ),
          Tooltip(
            message: 'Sign Out',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => signUserOut(context),
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
