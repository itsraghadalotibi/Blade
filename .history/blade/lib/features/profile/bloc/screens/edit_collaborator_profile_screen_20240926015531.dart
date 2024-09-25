import 'dart:io';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/utils/theme/custom_themes/multi_select_dialog_theme.dart';
import 'package:blade_app/widgets/custom_button.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/edit_collaborator_profile_event.dart';
import '../bloc/edit_collaborator_profile_state.dart';
import '../src/collaborator_profile_model.dart';

// Profile Image URL
const String defaultProfileImageUrl =
    'https://firebasestorage.googleapis.com/v0/b/blade-87cf7.appspot.com/o/profile_images%2F360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=0db52e6c-f589-451d-9d22-c81190c123a1';

class EditCollaboratorProfileScreen extends StatefulWidget {
  final CollaboratorProfileModel profile;

  const EditCollaboratorProfileScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  _EditCollaboratorProfileScreenState createState() =>
      _EditCollaboratorProfileScreenState();
}

class _EditCollaboratorProfileScreenState
    extends State<EditCollaboratorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _validateUrl(String? value, {required String platform}) {
    if (value != null && value.isNotEmpty) {
      final urlPattern =
          r'^(http|https):\/\/[a-zA-Z0-9\-.]+\.[a-zA-Z]{2,3}(/\S*)?$';
      final result = RegExp(urlPattern, caseSensitive: false).hasMatch(value);

      if (!result) {
        return 'Please enter a valid URL (e.g., https://example.com)';
      }

      // Check for platform-specific URLs
      if (platform == 'GitHub' && !value.contains('github.com')) {
        return 'Please enter a valid GitHub profile URL';
      }

      if (platform == 'LinkedIn' && !value.contains('linkedin.com')) {
        return 'Please enter a valid LinkedIn profile URL';
      }
    }
    return null; // No error if the field is empty (since it's optional)
  }

  // Controllers for fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _githubController;
  late TextEditingController _linkedInController;

  // Profile image
  File? _newProfileImage;
  final ImagePicker _picker = ImagePicker();

  // Skills multi-select dropdown
  List<String> _selectedSkills = [];

  @override
  @override
  void initState() {
    super.initState();

    // Initialize text controllers with profile data
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _githubController = TextEditingController(
        text: widget.profile.socialMediaLinks?['GitHub'] ?? '');
    _linkedInController = TextEditingController(
        text: widget.profile.socialMediaLinks?['LinkedIn'] ?? '');

    // Initialize _selectedSkills with the profile's current skills
    _selectedSkills = List<String>.from(widget.profile.skills ?? []);

    // Fetch available skills from the BLoC
    context.read<EditCollaboratorProfileBloc>().add(FetchSkills());
  }

  // Validation functions
  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your last name';
    }
    return null;
  }

  String? _validateBio(String? value) {
    if (value != null && value.length > 300) {
      return 'Bio must be less than 300 characters';
    }
    return null;
  }

  // Image picker function with compression
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Compress image to 50% quality
    );

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  // Save button functionality
  // Save button functionality
  void _onSaveButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      String? profileImageUrl =
          widget.profile.profilePhotoUrl; // Use existing profile image URL

      if (_newProfileImage != null) {
        // If the user has selected a new profile image, upload it
        try {
          final fileName = '${widget.profile.uid}_profile_image.png';
          final storageRef =
              FirebaseStorage.instance.ref().child('profile_images/$fileName');

          // Upload the file to Firebase Storage
          await storageRef.putFile(_newProfileImage!);

          // Get the downloadable URL for the uploaded image
          profileImageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          // Handle any errors during the upload
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload profile image: $e'),
            ),
          );
          return; // Stop further execution if upload fails
        }
      }

      // Now, save the updated profile information along with the new image URL
      final updatedProfile = CollaboratorProfileModel(
        uid: widget.profile.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _selectedSkills,
        profilePhotoUrl: profileImageUrl, // Use the new image URL if it exists
        socialMediaLinks: {
          'GitHub': _githubController.text.trim(),
          'LinkedIn': _linkedInController.text.trim(),
        },
      );

      context
          .read<EditCollaboratorProfileBloc>()
          .add(SaveCollaboratorProfile(updatedProfile));
    } else {
      // Handle validation failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Collaborator Profile')),
      body: BlocListener<EditCollaboratorProfileBloc,
          EditCollaboratorProfileState>(
        listener: (context, state) {
          if (state is CollaboratorProfileUpdateSuccess) {
            Navigator.pop(context, state.updatedProfile);
          } else if (state is CollaboratorProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile')),
            );
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 75,
                            backgroundColor: Colors.greenAccent,
                            child: CircleAvatar(
                              radius: 70,
                              backgroundImage: _newProfileImage != null
                                  ? FileImage(_newProfileImage!)
                                  : (widget.profile.profilePhotoUrl != null &&
                                          widget.profile.profilePhotoUrl!
                                              .isNotEmpty &&
                                          widget.profile.profilePhotoUrl !=
                                              defaultProfileImageUrl)
                                      ? NetworkImage(
                                          widget.profile.profilePhotoUrl!)
                                      : const AssetImage(
                                              'blade/assets/images/content/user.png')
                                          as ImageProvider,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(CupertinoIcons.camera,
                                color: TColors.primary),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      label: 'First Name*',
                      controller: _firstNameController,
                      validator: _validateFirstName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Last Name*',
                      controller: _lastNameController,
                      validator: _validateLastName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Bio (Optional)',
                      controller: _bioController,
                      maxLines: 3, // Allows multi-line input
                      maxLength: 300, // Show the counter out of 300
                      showCounter: true, // Display the character counter
                      prefixIcon:
                          Icon(CupertinoIcons.pencil, color: TColors.grey),
                      validator: (value) {
                        if (value != null && value.length > 300) {
                          return 'Bio must be less than 300 characters'; // Error message if the limit is exceeded
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<EditCollaboratorProfileBloc,
                        EditCollaboratorProfileState>(
                      builder: (context, state) {
                        if (state is SkillsLoaded) {
                          // Detect current theme
                          final isDarkMode =
                              Theme.of(context).brightness == Brightness.dark;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MultiSelectDialogField<String>(
                                items: state.availableSkills
                                    .map((skill) =>
                                        MultiSelectItem(skill, skill))
                                    .toList(),
                                initialValue: widget.profile.skills ?? [],
                                onConfirm: (results) {
                                  setState(() {
                                    _selectedSkills = results.cast<String>();
                                  });
                                },
                                title: const Text('Skills'),
                                buttonText:
                                    const Text('Select Skills (Optional)'),

                                // Customization for color and text
                                itemsTextStyle: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                                selectedColor: const Color(
                                    0xFFFD5336), // Orange selected check color
                                checkColor: Colors
                                    .white, // Color of the checkmark inside the box

                                // Dialog decoration
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    width: 1.5,
                                  ),
                                ),

                                // Display selected skills as chips
                                chipDisplay: MultiSelectChipDisplay(
                                  items: _selectedSkills.map((skill) {
                                    return MultiSelectItem(skill, skill);
                                  }).toList(),
                                  chipColor: Theme.of(context).primaryColor,
                                  textStyle:
                                      const TextStyle(color: Colors.white),
                                  onTap: (value) {
                                    setState(() {
                                      _selectedSkills.remove(value);
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        } else if (state is SkillsLoading) {
                          return const CircularProgressIndicator();
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'GitHub Profile Link (Optional)',
                      controller: _githubController,
                      validator: (value) => _validateUrl(value,
                          platform: 'GitHub'), // Validate GitHub URL
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      label: 'LinkedIn Profile Link (Optional)',
                      controller: _linkedInController,
                      validator: (value) => _validateUrl(value,
                          platform: 'LinkedIn'), // Validate LinkedIn URL
                    ),
                    const SizedBox(
                        height: 100), // Add some padding at the bottom
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: CustomButton(
                text: 'Save',
                onPressed: _onSaveButtonPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
