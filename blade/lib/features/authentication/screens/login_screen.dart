import 'package:blade_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import 'package:blade_app/widgets/custom_text_field.dart';

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

  static const String emailPattern =
      r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

  @override
  void initState() {
    super.initState();
    // Set up listeners for real-time validation
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
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          setState(() {
            isLoading = state is AuthenticationLoading;
          });

          if (state is AuthenticationAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Login Successful!',
                  style: TextStyle(color: Colors.green),
                ),
                backgroundColor: Colors.white,
              ),
            );
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
                    // Email input field with real-time validation
                    CustomTextField(
                      label: 'Email',
                      controller: emailController,
                      focusNode: emailFocusNode,
                      errorText: emailError,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Password input field with real-time validation
                    CustomTextField(
                      label: 'Password',
                      controller: passwordController,
                      obscureText: true,
                      focusNode: passwordFocusNode,
                      errorText: passwordError,
                    ),
                    const SizedBox(height: 16),
                    // Login button
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
      // Validate all fields after the button is pressed
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





