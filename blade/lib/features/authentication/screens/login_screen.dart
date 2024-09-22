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

  // Variable to show loading indicator
  bool isLoading = false;

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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Email input field
                    CustomTextField(
                      label: 'Email',
                      controller: emailController,

                      onTap: () {
                        if (emailController.value == null || emailController.text.isEmpty) {
                           'Please enter your email';
                        } else if (!RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(emailController.value.toString())) {
                           'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password input field
                    CustomTextField(
                      label: 'Password',
                      inputType: "password",
                      controller: passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null  && value!.length < 8 ) {
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
                        onPressed: isLoading?null: _onLoginButtonPressed,
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      child: Text("ForgetPassword?",
                        style: TextStyle(color: TColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline
                        ),),
                      onTap: (){
                        Navigator.of(context).pushNamed('/forgetPassword');
                      },
                    ),
                    SizedBox(height: 10,),
                    // Text asking if user doesn't have an account
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
                          // Navigate to the corresponding sign-up screen based on user type
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

  void _onLoginButtonPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthenticationBloc>().add(
            LoginRequested(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            ),
          );
    }
  }
}