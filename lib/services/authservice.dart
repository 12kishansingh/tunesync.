
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authservice {
  // google sign in 
  signInWithGoogle()async{
    // begin interactive sing in process
    final GoogleSignInAccount? gUser=await GoogleSignIn().signIn();
    // obtain auth details from request 
    final GoogleSignInAuthentication? gAuth=await gUser!.authentication;

    // create a new credentail for user 
    final credentail= GoogleAuthProvider.credential(
      accessToken: gAuth?.accessToken,
      idToken: gAuth?.idToken,
    );

    // sign in 
    return await FirebaseAuth.instance.signInWithCredential(credentail);

  }
}
