import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'student'; // Default role

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  // Fixed _signUp method with all required parameters
  Future<void> _signUp() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        String? error = await authService.signUpUser(
          emailController.text.trim(),
          passwordController.text.trim(),
          nameController.text.trim(),
          _selectedRole,  // Added role parameter
          context,        // Added context parameter
        );

        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Registration successful! Please log in."
                    )),
          );

          // Navigate to Login Screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen()),
          );
        } else {
          // Display error message
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error))
              );
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
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name Field
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if(value!.isEmpty) return "Please enter your full name";
                    return null;
                  }
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter your email";
                    return null;
                  }
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter your password";
                    if (value.length < 6) return "Password must be at least 6 characters";
                    return null;
                  }
                ),
                const SizedBox(height: 16),
                
                // Role Selection
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _signUp, // Call _signUp() method
                  child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),

                // Already have an account? Login Button
                TextButton(
                  onPressed: () {
                    // Navigate to Login Screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute( 
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text("Already have an account? Log in here."),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}