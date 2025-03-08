import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboards/student/student_dashboard_screen.dart';
import '../dashboards/teacher/dashboard_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _role;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate() || _role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the form and select a role.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully Signed Up'),
        backgroundColor: Colors.green,
      ),
    );
    try {
      // Firebase Auth SignUp
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _role,
      });

        // Wait for 1 second
        await Future.delayed(const Duration(seconds: 1));

        // Navigate based on role
        if (_role == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentDashboardScreen()),
          );
        } else if (_role == 'Teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
          );
        }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light Grey Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "TARA",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF), // Purple Title
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, "Full Name", Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField(_emailController, "Email", Icons.email, isEmail: true),
                    const SizedBox(height: 15),
                    _buildPasswordField(_passwordController, "Password", true),
                    const SizedBox(height: 15),
                    _buildPasswordField(_confirmPasswordController, "Confirm Password", false),
                    const SizedBox(height: 15),
                    _buildRoleDropdown(),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF), // Purple Button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _signUp,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Navigate back to login
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Color(0xFF6C63FF), fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)), // Purple Icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)), // Purple Border
        ),
      ),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return "Enter your $label";
        if (isEmail && !value.contains('@')) return "Enter a valid email";
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF6C63FF)), // Purple Icon
        suffixIcon: IconButton(
          icon: Icon(
            isPassword ? (_obscurePassword ? Icons.visibility : Icons.visibility_off)
                       : (_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)), // Purple Border
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Enter your $label";
        if (isPassword && value.length < 6) return "Min 6 characters required";
        if (!isPassword && value != _passwordController.text) return "Passwords do not match";
        return null;
      },
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "Role",
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)), // Purple Icon
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      value: _role,
      onChanged: (value) => setState(() => _role = value),
      items: const [
        DropdownMenuItem(value: "Student", child: Text("Student")),
        DropdownMenuItem(value: "Teacher", child: Text("Teacher")),
      ],
      validator: (value) => value == null ? "Select a role" : null,
    );
  }
}
