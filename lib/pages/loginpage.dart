import 'package:flutter/material.dart';
import 'package:tunesync/components/mytextfiled.dart';

class LoginPage extends StatelessWidget {

   LoginPage({super.key});
  final usernamecontroller=TextEditingController();
  final passwordcontroller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              // logo
              Image.asset(
                'lib/assets/pic2.png',
                width: 250,
              ),
              const SizedBox(
                height: 50,
              ),

              //welcome back
              Text(
                'Welcome back!!!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              // username textfield
              Mytextfiled(
                controller: usernamecontroller,
                hinttext: 'Username',
                obscuretext: false,
              ),

              const SizedBox(height: 10,),
              //passowrd textfield
              Mytextfiled(
                controller: passwordcontroller,
                hinttext: 'Password',
                obscuretext: true,
              ),
              const SizedBox(height: 10,),

              //forgot password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Forgot Password?',
                    style: TextStyle(color: Colors.grey[600]),),
                  ],
                ),
              ),
              //sign in button

              // or continue with

              // google sign in button

              // not a member , sign up!!!
            ],
          ),
        ),
      ),
    );
  }
}
