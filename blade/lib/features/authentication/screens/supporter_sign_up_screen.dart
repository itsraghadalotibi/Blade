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

     emailController.addListener(() {
      setState(() {
        emailError = _validateEmail(emailController.text);
      });
    });

    firstNameController.addListener(() {
      setState(() {
        firstNameError = _validateFirstName(firstNameController.text);
      });
    });

    lastNameController.addListener(() {
      setState(() {
        lastNameError = _validateLastName(lastNameController.text);
      });
    });

    passwordController.addListener(() {
      setState(() {
        passwordError = _validatePassword(passwordController.text);
      });
    });


    // Add listener to password controller
    passwordController.addListener(_updatePasswordValidation);
  }

  void _updatePasswordValidation() {
    final value = passwordController.text;

    setState(() {
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
      return 'Password must meet these requirements:';
    }

    return null;
  }

  // Method to pick image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Adjust quality to reduce size if needed
    );

    if (pickedFile != null) {
      // Get the file size
      final file = File(pickedFile.path);
      final int fileSizeInBytes = await file.length();

      // Define the maximum file size (e.g., 5 MB)
      const int maxFileSize = 5 * 1024 * 1024; // 5 MB in bytes

      if (fileSizeInBytes > maxFileSize) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: TColors.error,
              behavior: SnackBarBehavior.floating,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(CupertinoIcons.xmark_circle_fill,
                      color: Colors.white), // Change icon and color as needed
                  SizedBox(width: 8), // Space between icon and text
                  Expanded(
                    child: Text(
                      'Image size should not exceed 5MB',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              showCloseIcon: true),
        );
      } else {
        setState(() {
          _profileImage = file;
        });
      }
    }
  }

  Future<void> _onSignUpButtonPressed() async {
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
        email: emailController.text.trim().toLowerCase(),
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
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationLoading) {
            setState(() {
              isLoading = true;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
          if (state is AuthenticationUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: TColors.success,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(CupertinoIcons.check_mark_circled_solid,
                            color: Colors
                                .white), // Change icon and color as needed
                        const SizedBox(width: 8), // Space between icon and text
                        const Expanded(
                          child: Text(
                            'Sign Up Successful. Please log in.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    showCloseIcon: true),
              );
              Navigator.pushReplacementNamed(context, '/login', arguments: 'supporter');
          } else if (state is AuthenticationFailure) {
            if (state.error.contains("email-already-in-use")) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    backgroundColor: TColors.warning,
                    behavior: SnackBarBehavior.floating,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.exclamationmark_triangle_fill,
                            color: Colors
                                .white), // Change icon and color as needed
                        SizedBox(width: 8), // Space between icon and text
                        Expanded(
                          child: Text(
                            'Email is already registered',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    showCloseIcon: true),
              );
            } else {
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
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
            padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 24),

                    // First Name field with error handling
                    CustomTextField(
                      label: 'First Name*',
                      controller: firstNameController,
                      focusNode: firstNameFocusNode,
                      errorText: firstNameError,
                      maxLength: 50,
                      prefixIcon: const Icon(CupertinoIcons.person_fill, color: TColors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Last Name field with error handling
                    CustomTextField(
                      label: 'Last Name*',
                      controller: lastNameController,
                      focusNode: lastNameFocusNode,
                      errorText: lastNameError,
                      maxLength: 50,
                      prefixIcon: const Icon(CupertinoIcons.person_fill, color: TColors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Email field with error handling
                    CustomTextField(
                      label: 'Email*',
                      controller: emailController,
                      focusNode: emailFocusNode,
                      errorText: emailError,
                      prefixIcon: const Icon(CupertinoIcons.mail_solid, color: TColors.grey),

                    ),
                    const SizedBox(height: 16),

                    // Password field with error handling
                    CustomTextField(
                      label: 'Password*',
                      controller: passwordController,
                      obscureText: true,
                      focusNode: passwordFocusNode,
                      errorText: passwordError,
                      maxLength: 128,
                      prefixIcon: const Icon(CupertinoIcons.lock_fill, color: TColors.grey),
                    ),

                    // Display password requirements only when user starts typing
                    if (showPasswordRequirements) ...[
                      const SizedBox(height: 4),
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
                      maxLength: 300,
                      showCounter: true,
                      prefixIcon: const Icon(CupertinoIcons.pencil, color: TColors.grey),
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
                    const Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Create Account Outlined Button (OutlinedButton)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login', arguments: 'supporter');
                        },
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // The loading indicator overlay
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
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
            backgroundColor: const Color.fromARGB(255, 160, 234, 218),
            radius: 82,
            child: CircleAvatar(
              radius: 75,
              backgroundColor: TColors.secondary,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/images/content/user.png')
                        as ImageProvider,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.camera,
                color: TColors.primary,
                size: 32,
              ),
              onPressed: _pickImage,
            ),
          ),
        ],
      ),
    );
  }
}
