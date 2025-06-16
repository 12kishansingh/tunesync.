import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tunesync/services/audio_player.dart';
import 'firebase_options.dart';
import 'pages/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AudioPlayerService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuneSync',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthPage(),  // main authenticaiton at the entry point in the homepage 
      debugShowCheckedModeBanner: false,
    );
  }
}
