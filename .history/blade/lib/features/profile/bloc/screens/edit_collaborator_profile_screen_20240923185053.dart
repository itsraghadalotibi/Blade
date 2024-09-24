import 'dart:io';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/widgets/custom_button.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/edit_collaborator_profile_event.dart';
import '../bloc/edit_collaborator_profile_state.dart';
import '../src/collaborator_profile_model.dart';

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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;

  File? _newProfileImage; // Store the new profile image
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _skillsController = TextEditingController(
      text: widget.profile.skills?.join(', ') ?? '',
    );
  }

  // Function to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path); // Set the new image
      });
    }
  }

  // Method to save the profile updates
  void _saveProfile() {
    setState(() {
      _isLoading = true;
    });

    final updatedProfile = CollaboratorProfileModel(
      uid: widget.profile.uid,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      bio: _bioController.text,
      profilePhotoUrl: _newProfileImage != null
          ? _newProfileImage!.path
          : widget.profile.profilePhotoUrl, // Keep old image if not changed
      skills: _skillsController.text.split(',').map((s) => s.trim()).toList(),
    );

    // Dispatch the SaveCollaboratorProfile event
    context
        .read<EditCollaboratorProfileBloc>()
        .add(SaveCollaboratorProfile(updatedProfile));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collaborator Profile'),
      ),
      body: BlocListener<EditCollaboratorProfileBloc,
          EditCollaboratorProfileState>(
        listener: (context, state) {
          setState(() {
            _isLoading = false;
          });

          if (state is CollaboratorProfileUpdateSuccess) {
            Navigator.pop(context, state.updatedProfile);
          } else if (state is CollaboratorProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile')),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Image section
                    _buildProfileImage(),
                    const SizedBox(height: 24),

                    // First Name
                    CustomTextField(
                      label: 'First Name',
                      controller: _firstNameController,
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    CustomTextField(
                      label: 'Last Name',
                      controller: _lastNameController,
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    CustomTextField(
                      label: 'Bio',
                      controller: _bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Skills
                    CustomTextField(
                      label: 'Skills (comma separated)',
                      controller: _skillsController,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    CustomButton(
                      text: 'Save',
                      onPressed: _saveProfile,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Profile Image widget with editing option
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
              backgroundImage: _newProfileImage != null
                  ? FileImage(_newProfileImage!)
                  : AssetImage('assets/images/content/user.png')
                      as ImageProvider,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: TColors.primary),
            onPressed: _pickImage,
          ),
        ],
      ),
    );
  }
}
