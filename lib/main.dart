import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// ignore: unused_import

import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart'; // Ensure Firebase configuration is set up

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyC46wX-mshbXT08wRVrS-D2TIBotmJNnxY",
        authDomain: "aiteachingassistant-965a8.firebaseapp.com",
        projectId: "aiteachingassistant-965a8",
        storageBucket: "aiteachingassistant-965a8.appspot.com",
        messagingSenderId: "547885866567",
        appId: "1:547885866567:web:9d49e04092a10a244d1b62",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // For mobile platforms
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Teaching Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/auth-gate': (context) => const AuthGate(), // Add a route called /auth-gate
      },
      initialRoute: '/auth-gate',
    );
  }
}
