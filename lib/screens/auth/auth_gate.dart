import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dashboards/student/student_dashboard_screen.dart';
import '../dashboards/teacher/dashboard_screen.dart';
import 'auth_service.dart';
import 'login_screen.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? userRole;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          userRole = "guest"; // Redirect to login if not authenticated
        });
        return;
      }

      final userData = await _authService.getUserData(currentUser.uid);
      if (userData != null && userData.containsKey('role')) {
        setState(() {
          userRole = userData['role'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user role: $e");
      setState(() {
        userRole = "guest"; // Handle error by redirecting to login
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userRole == "guest") {
      return const LoginScreen(); // Redirect to login if not authenticated
    }

    return userRole == 'teacher' ? const TeacherDashboardScreen() : StudentDashboardScreen();
  }
}
