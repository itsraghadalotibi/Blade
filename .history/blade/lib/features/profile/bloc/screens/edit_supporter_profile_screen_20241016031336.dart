import 'dart:io';
import 'package:blade_app/features/profile/bloc/bloc/edit_supporter_profile_state.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: BlocListener<EditSupporterProfileBloc, EditSupporterProfileState>(
        listener: (context, state) {
          if (state is SupporterProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile')),
            );
          }
        },
        child: SingleChildScrollView(
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
                        backgroundColor:
                            Colors.greenAccent, // Add the green border
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: _newProfileImage != null
                              ? FileImage(_newProfileImage!)
                              : (widget.profile.profilePhotoUrl != null &&
                                      widget
                                          .profile.profilePhotoUrl!.isNotEmpty)
                                  ? NetworkImage(
                                      widget.profile.profilePhotoUrl!)
                                  : const AssetImage('assets/images/user.png')
                                      as ImageProvider,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(CupertinoIcons.camera,
                            color: TColors.primary),
                        onPressed: _pickImage, // Image picker function
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0), // Adjust the padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _firstNameController,
                        maxLength: 20, // Enforce character limit
                        decoration: const InputDecoration(
                          labelText: 'First Name*',
                          counterText: '', // Hides the counter text
                          border:
                              OutlineInputBorder(), // Add borders for a consistent look
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height:
                              24), // Add spacing between first and last name
                      TextFormField(
                        controller: _lastNameController,
                        maxLength: 20, // Enforce character limit
                        decoration: const InputDecoration(
                          labelText: 'Last Name*',
                          counterText: '', // Hides the counter text
                          border:
                              OutlineInputBorder(), // Add borders for a consistent look
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                          height: 24), // Add spacing between last name and bio
                      TextFormField(
                        controller: _bioController,
                        maxLength: 150, // Limit bio to 150 characters
                        decoration: const InputDecoration(
                          labelText: 'Bio (Optional)',
                          border:
                              OutlineInputBorder(), // Add border for bio field
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Custom save button
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: CustomButton(
                    text: 'Save',
                    onPressed: _onSaveButtonPressed,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(TColors.primary),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16.0)),
                      textStyle: MaterialStateProperty.all(
                          const TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
