import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tunesync/components/bybutton.dart';
import 'package:tunesync/components/mytextfiled.dart';
import 'package:tunesync/components/squretile.dart';
import 'package:tunesync/services/authservice.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key,required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernamecontroller = TextEditingController();

  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();

  //sign user up method
  void singUserUp() async {
    //show loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });

    // try sign up /create the user 
    try {
      //check if passoword and confirm password is same 
      if(passwordcontroller.text==confirmpasswordcontroller.text){
         await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usernamecontroller.text,
        password: passwordcontroller.text,
      );
      }
      else{
        // show the error message
        showErrorMessage("Password Do Not Match!");
      }
      //pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);
      //show error message
      showErrorMessage(e.code);
      
    }
  }

  // wrong email/username message
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.deepPurple,
            title: Center(
              child: Text(
                message,
                style:const TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
                ),
                // logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Image.asset(
                    'lib/assets/pic2.png',
                    width: 250,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Your Music, Your Way.',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 238, 25, 25),
                    fontSize: 25,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                //welcome back
                Text(
                  'Let\' create an account.',
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
                 
                //passowrd textfield
                Mytextfiled(
                  controller: confirmpasswordcontroller,
                  hinttext: 'Confirm Password',
                  obscuretext: true,
                ),
                const SizedBox(
                  height: 10,
                ),

                
                const SizedBox(
                  height: 25,
                ),

                //sign in button
                MyButton(
                  text: "Sign Up",
                  onTap: singUserUp,
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
                    SquareTile(imagepath: 'lib/assets/pic1.png',onTap: ()=>Authservice().signInWithGoogle(),),

                    // apple
                    const SizedBox(
                      width: 10,
                    ),

                    SquareTile(imagepath: 'lib/assets/pic3.png',onTap: (){},),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                // not a member , sign up!!!
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have a account.'),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'LogIn Now',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
