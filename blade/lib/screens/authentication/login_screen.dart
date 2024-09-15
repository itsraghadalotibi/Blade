import 'package:flutter/material.dart';
import 'package:blade_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final String userType; // 'student' or 'supporter'

  const LoginScreen({super.key, required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login as ${widget.userType == 'student' ? 'Student' : 'Supporter'}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email input field
              CustomTextField(
                label: 'Email',
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password input field
              CustomTextField(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Login button (ElevatedButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Proceed with login
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              // Text asking if user doesn't have an account
              const Text(
                "Don't have an account?",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 8),
              // Create Account Outlined Button (OutlinedButton)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to the corresponding sign-up screen based on user type
                    Navigator.pushNamed(
                      context,
                      widget.userType == 'student' ? '/signup-student' : '/signup-supporter',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    minimumSize: const Size(double.infinity, 50), // Full-width button
                  ),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
