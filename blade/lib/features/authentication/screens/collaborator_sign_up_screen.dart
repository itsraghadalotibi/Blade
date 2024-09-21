import 'dart:io';
import 'package:blade_app/utils/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/theme/custom_themes/multi_select_dialog_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/password_requirement.dart';
import '../bloc/authentication_bloc.dart';
import '../bloc/authentication_event.dart';
import '../bloc/authentication_state.dart';
import '../src/collaborator_model.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';


// Define a constant for the default profile image URL
const String defaultProfileImageUrl =
    'gs://blade-87cf7.appspot.com/profile_images/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg';

class CollaboratorSignUpScreen extends StatefulWidget {
  const CollaboratorSignUpScreen({Key? key}) : super(key: key);

  @override
  _CollaboratorSignUpScreenState createState() => _CollaboratorSignUpScreenState();
}

class _CollaboratorSignUpScreenState extends State<CollaboratorSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController githubController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();

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

  // Loading indicator
  bool isLoading = false;

  // Profile image variables
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Password validation variables
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasDigit = false;
  bool hasSpecialChar = false;
  bool isMinLength = false;
  bool showPasswordRequirements = false; // Initially set to false

  // Skills multi-select
  final List<MultiSelectItem<String>> _skillsItems = [
    MultiSelectItem('Agile Methodologies', 'Agile Methodologies'),
    MultiSelectItem('AI (Artificial Intelligence)', 'AI (Artificial Intelligence)'),
    MultiSelectItem('AWS (Amazon Web Services)', 'AWS (Amazon Web Services)'),
    MultiSelectItem('Blockchain', 'Blockchain'),
    MultiSelectItem('C#', 'C#'),
    MultiSelectItem('C++', 'C++'),
    MultiSelectItem('Cloud Computing', 'Cloud Computing'),
    MultiSelectItem('Cybersecurity', 'Cybersecurity'),
    MultiSelectItem('Data Analysis', 'Data Analysis'),
    MultiSelectItem('Data Science', 'Data Science'),
    MultiSelectItem('Dart', 'Dart'),
    MultiSelectItem('DevOps', 'DevOps'),
    MultiSelectItem('Docker', 'Docker'),
    MultiSelectItem('Embedded Systems', 'Embedded Systems'),
    MultiSelectItem('Game Development', 'Game Development'),
    MultiSelectItem('Git', 'Git'),
    MultiSelectItem('Go', 'Go'),
    MultiSelectItem('Graphic Design', 'Graphic Design'),
    MultiSelectItem('HTML/CSS', 'HTML/CSS'),
    MultiSelectItem('iOS Development', 'iOS Development'),
    MultiSelectItem('Java', 'Java'),
    MultiSelectItem('JavaScript', 'JavaScript'),
    MultiSelectItem('Kotlin', 'Kotlin'),
    MultiSelectItem('Laravel', 'Laravel'),
    MultiSelectItem('Machine Learning', 'Machine Learning'),
    MultiSelectItem('Mobile Development', 'Mobile Development'),
    MultiSelectItem('MongoDB', 'MongoDB'),
    MultiSelectItem('Node.js', 'Node.js'),
    MultiSelectItem('PHP', 'PHP'),
    MultiSelectItem('Project Management', 'Project Management'),
    MultiSelectItem('Python', 'Python'),
    MultiSelectItem('React', 'React'),
    MultiSelectItem('Ruby on Rails', 'Ruby on Rails'),
    MultiSelectItem('SQL', 'SQL'),
    MultiSelectItem('Swift', 'Swift'),
    MultiSelectItem('TypeScript', 'TypeScript'),
    MultiSelectItem('UI Design', 'UI Design'),
    MultiSelectItem('UX Design', 'UX Design'),
    MultiSelectItem('Web Development', 'Web Development'),
  ];

  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();

    // Listener for email field to reset isEmailUsed when email changes
    emailController.addListener(() {
      if (isEmailUsed) {
        setState(() {
          isEmailUsed = false;
          emailError = _validateEmail(emailController.text);
        });
      }
    });

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

    passwordController.addListener(_updatePasswordValidation);
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
    githubController.dispose();
    linkedInController.dispose();
    super.dispose();
  }

  void _updatePasswordValidation() {
    final value = passwordController.text;

    setState(() {
      showPasswordRequirements = value.isNotEmpty; // Show requirements when user starts typing
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasDigit = value.contains(RegExp(r'\d'));
      hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      isMinLength = value.length >= 8;
    });
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

    if (!hasUppercase || !hasLowercase || !hasDigit || !hasSpecialChar || !isMinLength) {
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

  // Handle sign-up button press
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
      // Check if email is already registered
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

      final socialMediaLinks = {
        if (githubController.text.trim().isNotEmpty) 'GitHub': githubController.text.trim(),
        if (linkedInController.text.trim().isNotEmpty) 'LinkedIn': linkedInController.text.trim(),
      };

      final collaborator = CollaboratorModel(
        uid: '',
        email: emailController.text.trim(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        skills: _selectedSkills,
        bio: bioController.text.trim(),
        socialMediaLinks: socialMediaLinks,
        profilePhotoUrl: profileImageUrl,
      );

      // Dispatch the sign-up event
      context.read<AuthenticationBloc>().add(
            SignUpCollaboratorRequested(
              collaborator: collaborator,
              password: passwordController.text.trim(),
              profileImage: _profileImage,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Collaborator Sign Up')),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          setState(() {
            isLoading = state is AuthenticationLoading;
          });

          if (state is AuthenticationUnauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign Up Successful. Please log in.')),
            );
            Navigator.pushReplacementNamed(context, '/login', arguments: 'collaborator');
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
                    const SizedBox(height: 8),

                    // Display password requirements only when typing
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

                    // Skills Multi-Select with Custom Theme
                    isDarkMode? TMultiSelectDialogTheme.darkMultiSelectDialogField(
                            items: _skillsItems,
                            selectedItems: _selectedSkills,
                            onConfirm: (results) {
                              setState(() {
                                _selectedSkills = results;
                              });
                            },
                            title: 'Skills',
                            buttonText: 'Select Skills (Optional)',
                          )
                        : TMultiSelectDialogTheme.lightMultiSelectDialogField(
                            items: _skillsItems,
                            selectedItems: _selectedSkills,
                            onConfirm: (results) {
                              setState(() {
                                _selectedSkills = results;
                              });
                            },
                            title: 'Skills',
                            buttonText: 'Select Skills (Optional)',
                          ),
                    const SizedBox(height: 16),

                    // Bio field
                    CustomTextField(
                      label: 'Bio (Optional)',
                      controller: bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // GitHub Link
                    CustomTextField(
                      label: 'GitHub Profile Link',
                      controller: githubController,
                    ),
                    const SizedBox(height: 16),

                    // LinkedIn Link
                    CustomTextField(
                      label: 'LinkedIn Profile Link',
                      controller: linkedInController,
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
                        Navigator.pushReplacementNamed(context, '/login', arguments: 'collaborator');
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

