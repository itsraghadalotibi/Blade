
import 'package:blade_app/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override _ForgetPasswordScreenState createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _emailController = TextEditingController();

  bool vaildateEmail(String email) {
    final RegExp exp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return exp.hasMatch(email);
  }

  Future<void> _sendResetLink() async {
    final email = _emailController.text;
    if (email.isEmpty && vaildateEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }
    try { // Send a password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show a success message      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reset link sent to $email'));
    } catch (e) {
      // Show an error message      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error sending reset link: $e')
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      title: const Text('Forgot Password'),),
      body: Padding(padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.all(10),
              child: TextFormField(

                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Enter your email'),
                keyboardType: TextInputType.emailAddress,),),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    maximumSize: Size.fromWidth(double.infinity),
                    backgroundColor: TColors.primary
                ),
                onPressed: _sendResetLink,
                child: const Text('Send Reset Link'),
              ),
            )
          ],
        ),),
    );
  }
}