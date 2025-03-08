import 'package:flutter/material.dart';
import 'package:ai_teaching_assistant/screens/dashboards/student/student_dashboard_screen.dart';
import 'package:ai_teaching_assistant/screens/dashboards/teacher/dashboard_screen.dart';
import 'package:ai_teaching_assistant/screens/auth/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? userRole;
  final AuthService _authService = AuthService();

  @override 
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    String? role = await _authService.getUserRole();
    setState(() {
      userRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return userRole == 'teacher'
        ? const TeacherDashboardScreen()
        : const StudentDashboardScreen();
  }
}
