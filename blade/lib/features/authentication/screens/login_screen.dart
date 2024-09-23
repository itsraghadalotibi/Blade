import 'package:blade_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import 'package:blade_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final String userType; // 'collaborator' or 'supporter'

  const LoginScreen({super.key, required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool hasPressedButton = false; // Track button press

  @override
  Widget build(BuildContext context) {
    String userTypeCapitalized = widget.userType[0].toUpperCase() + widget.userType.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Login as $userTypeCapitalized'),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          setState(() {
            isLoading = state is AuthenticationLoading;
          });

          if (state is AuthenticationAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthenticationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login Failed: ${state.error}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email input field
                    CustomTextField(
                      label: 'Email',
                      controller: emailController,
                      validator: (value) {
                        if (hasPressedButton) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
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
                        if (hasPressedButton) {
                          if (value == null || value.length < 8) {
                            return 'Please enter a password of at least 8 characters';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Login button (ElevatedButton)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onLoginButtonPressed,
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      child: Text(
                        "Forget Password? Reset",
                        style: TextStyle(
                          color: TColors.info,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed('/forgetPassword');
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Create Account Outlined Button (OutlinedButton)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            widget.userType == 'collaborator' ? '/collaboratorSignUp' : '/supporterSignUp',
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onLoginButtonPressed() async {
    setState(() {
      hasPressedButton = true; // Mark that the button was pressed
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final authBloc = context.read<AuthenticationBloc>();
      final userTypeFromRepo = await authBloc.authenticationRepository.getUserTypeByEmail(emailController.text.trim());

      if (userTypeFromRepo != null && userTypeFromRepo != widget.userType) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: You are trying to log in as a ${widget.userType}, but your account is registered as a $userTypeFromRepo.'),
          ),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      authBloc.add(
        LoginRequested(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          userType: widget.userType, // Pass the userType
        ),
      );
    } else {
      setState(() {
        isLoading = false; // Reset loading state if validation fails
      });
    }
  }
}