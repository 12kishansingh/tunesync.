import 'package:flutter/material.dart';
import 'package:tunesync/components/bybutton.dart';
import 'package:tunesync/components/mytextfiled.dart';
import 'package:tunesync/components/squretile.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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

              const SizedBox(
                height: 10,
              ),
              //passowrd textfield
              Mytextfiled(
                controller: passwordcontroller,
                hinttext: 'Password',
                obscuretext: true,
              ),
              const SizedBox(
                height: 10,
              ),

              //forgot password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              //sign in button
              MyButton(
                onTap: () {},
              ),
              const SizedBox(
                height: 40,
              ),
              // or continue with
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: .5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Or Continue With'),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: .5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),

              // google sign in button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google
                  SquareTile(imagepath: 'lib/assets/pic1.png'),

                  // apple
                  const SizedBox(
                    width: 10,
                  ),

                  SquareTile(imagepath: 'lib/assets/pic3.png'),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              // not a member , sign up!!!
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member?'),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
