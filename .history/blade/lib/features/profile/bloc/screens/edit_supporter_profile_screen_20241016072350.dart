import 'dart:io';
import 'package:blade_app/features/profile/bloc/bloc/edit_supporter_profile_state.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
// import '../../../utils/constants/colors.dart'; // Removed duplicate import
import 'package:blade_app/widgets/custom_text_field.dart';
import '../bloc/edit_supporter_profile_bloc.dart';
import '../bloc/edit_supporter_profile_event.dart';
import '../src/supporter_profile_model.dart';

class EditSupporterProfileScreen extends StatefulWidget {
  final SupporterProfileModel profile;

  const EditSupporterProfileScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  _EditSupporterProfileScreenState createState() =>
      _EditSupporterProfileScreenState();
}

class _EditSupporterProfileScreenState
    extends State<EditSupporterProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;

  // Profile image handling
  File? _newProfileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with existing profile data
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
  }

  // Image picker function
  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  // Save button functionality
  void _onSaveButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      String? profileImageUrl = widget.profile.profilePhotoUrl;

      if (_newProfileImage != null) {
        try {
          final fileName = '${widget.profile.uid}_profile_image.png';
          final storageRef =
              FirebaseStorage.instance.ref().child('profile_images/$fileName');
          final uploadTask = await storageRef.putFile(_newProfileImage!);

          if (uploadTask.state == TaskState.success) {
            profileImageUrl = await storageRef.getDownloadURL();
          } else {
            throw Exception("Upload failed");
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload profile image: $e')),
          );
          return;
        }
      }

      // Dispatch the SaveSupporterProfile event to update the profile
      final updatedProfile = SupporterProfileModel(
        uid: widget.profile.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
        profilePhotoUrl: profileImageUrl,
      );

      context
          .read<EditSupporterProfileBloc>()
          .add(SaveSupporterProfile(updatedProfile));

      // Pass the updated profile back to the previous screen
      Navigator.pop(context, updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supporter Edit Profile'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: BlocListener<EditSupporterProfileBloc, EditSupporterProfileState>(
        listener: (context, state) {
          if (state is SupporterProfileUpdateFailure) {
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
                key: _formKey, // Ensure form key is added
                autovalidateMode: AutovalidateMode
                    .onUserInteraction, // Automatically validate fields
                child: Column(
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 24),

                    // First Name field with validator
                    CustomTextField(
                      label: 'First Name*',
                      controller: _firstNameController,
                      maxLength: 50,
                      prefixIcon: const Icon(
                        CupertinoIcons.person_fill, // Add icon
                        color: TColors.grey,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name field with validator
                    CustomTextField(
                      label: 'Last Name*',
                      controller: _lastNameController,
                      maxLength: 50,
                      prefixIcon: const Icon(
                        CupertinoIcons.person_fill, // Add icon
                        color: TColors.grey,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bio field with icon and theme
                    CustomTextField(
                      label: 'Bio (Optional)',
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 150,
                      showCounter: true,
                      prefixIcon: const Icon(
                        CupertinoIcons.pencil, // Add icon
                        color: TColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button with theme
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onSaveButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
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
                backgroundImage: _newProfileImage != null
                    ? FileImage(_newProfileImage!)
                    : (widget.profile.profilePhotoUrl != null &&
                            widget.profile.profilePhotoUrl!.isNotEmpty)
                        ? NetworkImage(widget.profile.profilePhotoUrl!)
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
