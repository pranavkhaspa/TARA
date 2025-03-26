import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  String selectedRole = 'student';

  final AuthService _authService = AuthService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Register the user using AuthService
        String? error = await _authService.signUpUser(
          emailController.text.trim(),
          passwordController.text.trim(),
          fullNameController.text.trim(),
          selectedRole,  // Pass the selected role to the AuthService
          context,
        );

        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration successful! Please log in.")),
          );

          // Navigate to Login Screen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full Name Field
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Please enter your full name" : null,
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? "Please enter your email" : null,
              ),
              const SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? "Password must be at least 6 characters" : null,
              ),
              const SizedBox(height: 16),

              // Role Selection Dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['student', 'teacher'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
