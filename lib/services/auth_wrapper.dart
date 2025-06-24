import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunesync/pages/home_page.dart';
import 'package:tunesync/pages/login_or_register.dart';
import 'package:tunesync/services/audio_player.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Handle initial connection state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is signed in
        if (snapshot.hasData) {
          return ChangeNotifierProvider(
            create: (context) => AudioPlayerService(),
            child: const HomePage(),
          );
        }
        
        // User is signed out
        return const LoginOrRegister();
      },
    );
  }
}
