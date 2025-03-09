import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Log in user
  Future<String?> loginUser(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Return null if no error occurs
    } catch (e) {
      // Firebase specific error handling
      if (e is FirebaseAuthException) {
        return e.message; // Return Firebase specific error message
      }
      return "An error occurred: $e"; // Default error message
    }
  }

  // Sign up user
  Future<String?> signUpUser(String email, String password, String fullName,
      String role, BuildContext context) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store user details in Firestore, including the role
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'fullName': fullName,
        'role': role, // Use the role passed from the registration form
      });

      return null; // Return null if successful
    } catch (e) {
      debugPrint("Error occurred during registration: $e");

      // Firebase specific error handling
      if (e is FirebaseAuthException) {
        return e.message; // Return Firebase specific error message
      }
      return "An error occurred: $e"; // Default error message
    }
  }

  // Get user role based on email
  Future<String?> getUserRole({String? email}) async {
    debugPrint('Checking email in getUserRole: $email');
    try {
      // Check domain of email to assign a role (can be customized)
      if (email != null) {
        if (email.endsWith('teacher.com')) {
          return 'teacher';
        } else if (email.endsWith('student.com')) {
          return 'student';
        }
      }
      return null;
    } catch (e) {
      debugPrint("Error checking user role: $e");
      return null; // Return null if any error occurs
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint("Error getting user data: $e");
      return null;
    }
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } catch (e) {
      if (e is FirebaseAuthException) {
        return e.message;
      }
      return "An error occurred: $e";
    }
  }

  // Store a document in Firestore
  Future<String?> uploadDocument(
      String userId, String documentName, String documentUrl) async {
    try {
      // Store document in the "documents" collection, under the user's ID
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .add({
        'documentName': documentName,
        'documentUrl': documentUrl,
        'uploadDate': FieldValue.serverTimestamp(),
      });
      return null; // Return null if no error
    } catch (e) {
      debugPrint("Error uploading document: $e");
      return "An error occurred while uploading the document: $e";
    }
  }

  // Retrieve user's documents
  Future<List<Map<String, dynamic>>> getUserDocuments(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .get();

      List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => {
                'documentName': doc['documentName'],
                'documentUrl': doc['documentUrl'],
                'uploadDate': doc['uploadDate'],
              })
          .toList();

      return documents;
    } catch (e) {
      debugPrint("Error fetching documents: $e");
      return []; // Return empty list if there's an error
    }
  }

  // Upload file to Firebase Storage
  Future<String?> uploadFileToStorage(String userId, String filePath) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('userFiles')
          .child(userId)
          .child(
              'assignment_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}');
      await storageRef.putFile(File(filePath));
      String fileUrl = await storageRef.getDownloadURL();
      return fileUrl;
    } catch (e) {
      return "Error uploading file: $e";
    }
  }
}
