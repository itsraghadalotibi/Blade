import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:blade_app/widgets/custom_button.dart';

class SupporterSignUpScreen extends StatefulWidget {
  const SupporterSignUpScreen({super.key});

  @override
  _SupporterSignUpScreenState createState() => _SupporterSignUpScreenState();
}

class _SupporterSignUpScreenState extends State<SupporterSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController socialMediaController = TextEditingController();

  // FocusNodes for each field
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  // Field-specific error variables
  String? emailError;
  String? firstNameError;
  String? lastNameError;
  String? passwordError;

  @override
  void initState() {
    super.initState();

    // Add listeners to FocusNodes to trigger validation when losing focus
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        setState(() {
          emailError = _validateEmail(emailController.text);
        });
      }
    });

    firstNameFocusNode.addListener(() {
      if (!firstNameFocusNode.hasFocus) {
        setState(() {
          firstNameError = _validateFirstName(firstNameController.text);
        });
      }
    });

    lastNameFocusNode.addListener(() {
      if (!lastNameFocusNode.hasFocus) {
        setState(() {
          lastNameError = _validateLastName(lastNameController.text);
        });
      }
    });

    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus) {
        setState(() {
          passwordError = _validatePassword(passwordController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  // Custom validation functions for each field
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (!RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supporter Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 24),

              // Email field with error handling
              CustomTextField(
                label: 'Email',
                controller: emailController,
                focusNode: emailFocusNode,
                errorText: emailError,
              ),
              const SizedBox(height: 16),

              // First Name field with error handling
              CustomTextField(
                label: 'First Name',
                controller: firstNameController,
                focusNode: firstNameFocusNode,
                errorText: firstNameError,
              ),
              const SizedBox(height: 16),

              // Last Name field with error handling
              CustomTextField(
                label: 'Last Name',
                controller: lastNameController,
                focusNode: lastNameFocusNode,
                errorText: lastNameError,
              ),
              const SizedBox(height: 16),

              // Password field with error handling
              CustomTextField(
                label: 'Password',
                controller: passwordController,
                obscureText: true,
                focusNode: passwordFocusNode,
                errorText: passwordError,
              ),
              const SizedBox(height: 16),

              // Other optional fields
              CustomTextField(label: 'Bio (Optional)', controller: bioController),
              const SizedBox(height: 16),
              CustomTextField(label: 'Social Media Links (Optional)', controller: socialMediaController),
              const SizedBox(height: 24),

              // Sign Up Button
              CustomButton(
                text: 'Sign Up',
                onPressed: () {
                  setState(() {
                    emailError = _validateEmail(emailController.text);
                    firstNameError = _validateFirstName(firstNameController.text);
                    lastNameError = _validateLastName(lastNameController.text);
                    passwordError = _validatePassword(passwordController.text);
                  });

                  if (emailError == null &&
                      firstNameError == null &&
                      lastNameError == null &&
                      passwordError == null) {
                    // Proceed with sign-up logic if no errors
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the profile image at the top
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 75,
            backgroundImage: AssetImage('assets/images/content/user.png'), // Default profile image
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: Icon(CupertinoIcons.camera, color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                // Logic to change profile image
              },
            ),
          ),
        ],
      ),
    );
  }
}

