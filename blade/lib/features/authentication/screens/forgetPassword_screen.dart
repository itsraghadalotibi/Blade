import 'package:blade_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // To store the email validation state
  String? _emailError;

  bool validateEmail(String email) {
    final RegExp exp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return exp.hasMatch(email);
  }

  void _validateEmail() {
    final email = _emailController.text;
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address';
      });
    } else if (!validateEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
    } else {
      setState(() {
        _emailError = null; // Clear the error if email is valid
      });
    }
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text;

    // Validate email before sending the reset link
    _validateEmail(); // Check for validity

    if (_emailError != null) {
      // Show error if there's an issue with the email
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_emailError!)), // Display error message
      );
      return; // Don't proceed if there's an email error
    }

    // Check if email exists in Firestore collections
    try {
      final collaboratorSnapshot = await _firestore.collection('collaborators').where('email', isEqualTo: email).get();
      final supporterSnapshot = await _firestore.collection('supporters').where('email', isEqualTo: email).get();

      if (collaboratorSnapshot.docs.isEmpty && supporterSnapshot.docs.isEmpty) {
        // Email not found in both collections
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found for this email.')),
        );
        return;
      }

      // If the email exists, send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Show a success message with green background
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset link sent to $email successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Handle errors
      String errorMessage = 'An unknown error occurred.';
      if (e is FirebaseAuthException) {
        errorMessage = 'Error sending reset link: ${e.message}';
      }

      // Show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail); // Listen to changes in the email input
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  errorText: _emailError, // Show error if exists
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  maximumSize: Size.fromWidth(double.infinity),
                  backgroundColor: TColors.primary,
                ),
                onPressed: _sendResetLink,
                child: const Text('Send Reset Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


