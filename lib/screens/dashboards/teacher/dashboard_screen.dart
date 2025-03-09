import 'package:flutter/material.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Dashboard')),
      body: const Center(
        child: Text(
          'Welcome, Teacher!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
