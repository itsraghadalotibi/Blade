import 'package:blade_app/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import 'package:blade_app/widgets/custom_text_field.dart';

import '../src/collaborator_model.dart';

class LoginScreen extends StatefulWidget {
  final String userType;

  const LoginScreen({super.key, required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  String? emailError;
  String? passwordError;

  bool isLoading = false;
  bool isPasswordVisible = false; // Added for password visibility toggle

  static const String emailPattern = r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmailField);
    passwordController.addListener(_validatePasswordField);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userTypeCapitalized =
        widget.userType[0].toUpperCase() + widget.userType.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text('Login as $userTypeCapitalized'),
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          setState(() {
            isLoading = state is AuthenticationLoading;
          });

          if (state is AuthenticationAuthenticated) {
            final user = state.user;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: TColors.success,
                  behavior: SnackBarBehavior.floating,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.check_mark_circled_solid,
                          color:
                              Colors.white), // Change icon and color as needed
                      const SizedBox(width: 8), // Space between icon and text
                      const Expanded(
                        child: Text(
                          'Login Successful!',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  showCloseIcon: true),
            );
            if (user is CollaboratorModel) {
              Navigator.pushReplacementNamed(context, '/collaboratorHome');
            } else{
              Navigator.pushReplacementNamed(context, '/supporterHome');
            }
          } else if (state is AuthenticationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: TColors.error,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.xmark_circle_fill,
                            color: Colors
                                .white), // Change icon and color as needed
                        const SizedBox(width: 8), // Space between icon and text
                        Expanded(
                          child: Text(
                            'Sign Up Failed: ${state.error}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    showCloseIcon: true),
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
                    CustomTextField(
                      label: 'Email',
                      controller: emailController,
                      focusNode: emailFocusNode,
                      errorText: emailError,
                      prefixIcon: const Icon(CupertinoIcons.mail_solid, color: TColors.grey),
                      maxLength: 320,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Password',
                      controller: passwordController,
                      obscureText:
                          !isPasswordVisible, // Toggle password visibility
                      focusNode: passwordFocusNode,
                      errorText: passwordError,
                      maxLength: 128,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill, color: TColors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onLoginButtonPressed,
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: TColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed('/forgetPassword');
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            widget.userType == 'collaborator'
                                ? '/collaboratorSignUp'
                                : '/supporterSignUp',
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

  // Real-time email validation
  void _validateEmailField() {
    setState(() {
      emailError = _validateEmail(emailController.text);
    });
  }

  // Real-time password validation
  void _validatePasswordField() {
    setState(() {
      passwordError = _validatePassword(passwordController.text);
    });
  }

  // Email validation logic
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    } else if (!RegExp(emailPattern).hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  // Password validation logic
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  // Function triggered when login button is pressed
  void _onLoginButtonPressed() async {
    setState(() {
      _validateEmailField();
      _validatePasswordField();
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final authBloc = context.read<AuthenticationBloc>();
      final userTypeFromRepo = await authBloc.authenticationRepository
          .getUserTypeByEmail(emailController.text.trim());

      if (userTypeFromRepo != null && userTypeFromRepo != widget.userType) {
          ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    backgroundColor: TColors.error,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.xmark_circle_fill,
                            color: Colors
                                .white), // Change icon and color as needed
                        const SizedBox(width: 8), // Space between icon and text
                        Expanded(
                          child: Text(
                            'Error: You are trying to log in as a ${widget.userType}, but your account is registered as a $userTypeFromRepo.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    showCloseIcon: true),
              );
        
        setState(() {
          isLoading = false;
        });
        return;
      }

      authBloc.add(
        LoginRequested(
          email: emailController.text.trim().toLowerCase(),
          password: passwordController.text.trim(),
          userType: widget.userType,
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
}
