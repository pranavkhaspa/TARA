import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key}); // Constructor

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null; // User canceled sign-in
      }

      // Obtain the Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential using the token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error during Google Sign-In: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            UserCredential? userCredential = await signInWithGoogle();
            if (userCredential != null) {
              debugPrint("User Signed In: ${userCredential.user?.displayName}");
            } else {
              debugPrint("Google Sign-In failed");
            }
          },
          child: const Text("Sign in with Google"),
        ),
      ),
    );
  }
}
