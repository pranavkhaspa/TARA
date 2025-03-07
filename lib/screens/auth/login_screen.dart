import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // This method will handle the login logic.
  void _login() {
    // Here we can check the username and password.
    // For now, let's print the values.
    print("Username: ${_usernameController.text}");
    print("Password: ${_passwordController.text}");
    // TODO: Implement the actual login logic here.
  }
  
  // Navigate to the sign up screen
  void _signUp() {
   Navigator.of(context).pushNamed('/signup');
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFEEEEEE),
                      Color(0xFFDDDDDD),
                      Color(0xFFCCCCCC),
                    ]
                  )
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 120
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/images/login_image.png', height: 150, width: 150), // Replace with your image path
                       const SizedBox(height: 32),
                        TextFormField(
                        controller: _usernameController,
                         decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.person),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? 'Please enter your username' : null,
                          onSaved: (value) => _usernameController.text = value!,

                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                           focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                            enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true, // Hide the password
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text('Login', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _signUp,
                        child: const Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
