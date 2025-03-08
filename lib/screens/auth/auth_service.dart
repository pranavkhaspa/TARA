import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../home_screen.dart';
import '../dashboards/teacher/dashboard_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ REGISTER USER
  Future<String?> registerUser(String email, String password, String role) async {
    try {
      // Register user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
        'uid': userCredential.user!.uid,
      });

      return null; // Success, return null (no error)
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Registration failed. Please try again.";
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // ✅ LOGIN USER (Ensures Role-Based Navigation)
  Future<String?> loginUser(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Fetch user role and navigate immediately
      String? role = await getUserRole();
      if (role != null) {
        print("Navigating to: $role"); // Debugging print
        navigateUser(role, context);
        return null; // No error
      } else {
        return "User role not found. Contact support.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed. Please try again.";
    } catch (e) {
      return "An unexpected error occurred: $e";
    }
  }

  // ✅ FETCH USER ROLE FROM FIRESTORE
  Future<String?> getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc["role"]; // Returns "student" or "teacher"
      }
    }
    return null;
  }

  // ✅ NAVIGATE USER BASED ON ROLE
  void navigateUser(String role, BuildContext context) {
    Widget targetScreen;

    if (role.toLowerCase() == "student") {
      targetScreen = const HomeScreen();
    } else if (role.toLowerCase() == "teacher") {
      targetScreen = const TeacherDashboardScreen(); // Teacher dashboard
    } else {
      targetScreen = const HomeScreen(); // Default fallback
    }

    print("Pushing new screen: $role"); // Debugging print

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  // ✅ LOGOUT USER
  Future<void> logoutUser(BuildContext context) async {
    await _auth.signOut();
    // Navigate back to login screen (Assuming login screen is the first screen)
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ✅ GET CURRENT USER (Optional Helper)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
