import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tunesync/pages/home_page.dart';
import 'package:tunesync/pages/login_or_register.dart';
import 'package:tunesync/pages/loginpage.dart';


// to check if user is signed in or not
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context,snapshot){
          // user is logged in 
          if(snapshot.hasData){
            return HomePage();
          }

          //uer not logged in
          else{
            return LoginOrRegister();
          }

        },
      ),
    );
  }
}
