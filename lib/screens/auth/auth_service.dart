import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// `AuthService` handles authentication-related operations using Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// `signOut` signs out the current user from Firebase.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print("Error during sign-out: $e");
      }
    }
  }

  /// Gets the currently authenticated user.
  User? get currentUser => _auth.currentUser;


  }

