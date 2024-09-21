import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/constants/colors.dart';
import '../../../widgets/password_requirement.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:blade_app/widgets/custom_button.dart';
import '../src/supporter_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// Define a constant for the default profile image URL
const String defaultProfileImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/blade-87cf7.appspot.com/o/profile_images%2F360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=0db52e6c-f589-451d-9d22-c81190c123a1';

class SupporterSignUpScreen extends StatefulWidget {
  const SupporterSignUpScreen({Key? key}) : super(key: key);

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
  bool isEmailUsed = false; // Track if the email is already used

  // Variable to show loading indicator
  bool isLoading = false;

  // New variables for profile image
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Password validation variables
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool isMinLength = false;

  // Variable to control visibility of password requirements
  bool showPasswordRequirements = false;

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

    // Add listener to password controller
    passwordController.addListener(_updatePasswordValidation);
  }

  void _updatePasswordValidation() {
    final value = passwordController.text;

    setState(() {
      // Update validation flags
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasDigit = value.contains(RegExp(r'\d'));
      hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      isMinLength = value.length >= 8;

      // Show password requirements when user starts typing
      showPasswordRequirements = value.isNotEmpty;
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    bioController.dispose();
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
    }

    final hasUppercase = value.contains(RegExp(r'[A-Z]'));
    final hasLowercase = value.contains(RegExp(r'[a-z]'));
    final hasDigit = value.contains(RegExp(r'\d'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final isMinLength = value.length >= 8;

    if (!hasUppercase ||
        !hasLowercase ||
        !hasDigit ||
        !hasSpecialChar ||
        !isMinLength) {
      return 'Password does not meet the requirements';
    }

    return null;
  }

  // Method to pick image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // or ImageSource.camera
      imageQuality: 80, // Adjust quality as needed
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

   // Check if email already exists
  Future<bool> _checkEmailExists(String email) async {
    try {
      final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return list.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onSignUpButtonPressed() async {
    setState(() {
      emailError = _validateEmail(emailController.text);
      firstNameError = _validateFirstName(firstNameController.text);
      lastNameError = _validateLastName(lastNameController.text);
      passwordError = _validatePassword(passwordController.text);
      isEmailUsed = false; // Reset in case it was set before
    });

    if (emailError == null &&
        firstNameError == null &&
        lastNameError == null &&
        passwordError == null) {
      bool emailExists = await _checkEmailExists(emailController.text.trim());
      if (emailExists) {
        setState(() {
          isEmailUsed = true;
          emailError = 'This email is already registered.';
        });
        return;
      }

       String profileImageUrl;

      if (_profileImage != null) {
        // Upload custom profile image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${emailController.text}_profile.png');
        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
      } else {
        // Use default image URL
        profileImageUrl = defaultProfileImageUrl;
      }
      // Create a SupporterModel
      final supporter = SupporterModel(
        uid: '',
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        bio: bioController.text.trim(),
        profilePhotoUrl: profileImageUrl,
      );

      // Dispatch SignUpSupporterRequested event, include the image file if selected
      context.read<AuthenticationBloc>().add(
            SignUpSupporterRequested(
              supporter: supporter,
              password: passwordController.text.trim(),
              profileImage: _profileImage,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supporter Sign Up'),
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          setState(() {
            isLoading = state is AuthenticationLoading;
          });

          if (state is AuthenticationUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign Up Successful. Please log in.')),
            );
            Navigator.pushReplacementNamed(context, '/login', arguments: 'supporter');
          } else if (state is AuthenticationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign Up Failed: ${state.error}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Form(
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
                      keyboardType: TextInputType.emailAddress,
                    ),
                    

                    // Show error and login button if email is already used
                    if (isEmailUsed) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Text(
                              "Already registered?",
                              style: TextStyle(color: Colors.red),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(context, '/login', arguments: 'collaborator');
                              },
                              child: const Text(
                                "Log In",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    

                    // Display password requirements only when user starts typing
                    if (showPasswordRequirements) ...[
                      PasswordRequirement(
                        requirement: 'At least 8 characters',
                        isMet: isMinLength,
                      ),
                      PasswordRequirement(
                        requirement: 'Contains uppercase letter',
                        isMet: hasUppercase,
                      ),
                      PasswordRequirement(
                        requirement: 'Contains lowercase letter',
                        isMet: hasLowercase,
                      ),
                      PasswordRequirement(
                        requirement: 'Contains digit',
                        isMet: hasDigit,
                      ),
                      PasswordRequirement(
                        requirement: 'Contains special character',
                        isMet: hasSpecialChar,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Bio field
                    CustomTextField(
                      label: 'Bio (Optional)',
                      controller: bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                      onPressed: isLoading ? null : _onSignUpButtonPressed,
                      child: const Text('Sign Up'),
                    ),
                    ),

                     const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login', arguments: 'supporter');
                      },
                      child: const Text(
                        'Already have an account? Log In',
                      ),
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

  /// Build the profile image at the top
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 75,
            backgroundColor: TColors.secondary,
            child: CircleAvatar(
              radius: 73,
              backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : const AssetImage('assets/images/content/user.png') as ImageProvider,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: Icon(CupertinoIcons.camera, color: TColors.primary),
              onPressed: _pickImage,
            ),
          ),
        ],
      ),
    );
  }
}
