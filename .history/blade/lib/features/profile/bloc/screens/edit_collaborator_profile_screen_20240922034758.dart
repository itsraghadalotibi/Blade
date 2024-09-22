// Path: lib/features/profile/screens/edit_collaborator_profile_screen.dart

import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Image picker
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditCollaboratorProfileBloc,
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Display profile photo
            GestureDetector(
              onTap: _pickImage, // Open gallery on tap
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _newProfileImage != null
                    ? FileImage(_newProfileImage!) // Show new image if picked
                    : NetworkImage(widget.profile.profilePhotoUrl ??
                            'https://placeholder.com')
                        as ImageProvider, // Show existing image
                child: Icon(Icons.camera_alt, size: 30), // Camera icon
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            TextField(
              controller: _skillsController,
              decoration:
                  const InputDecoration(labelText: 'Skills (comma separated)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Split the comma-separated string into a list of skills
                final skillsList = _skillsController.text
                    .split(',')
                    .map((skill) => skill.trim())
                    .toList();

                final updatedProfile = CollaboratorProfileModel(
                  uid: widget.profile.uid,
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  bio: _bioController.text,
                  profilePhotoUrl: _newProfileImage != null
                      ? _newProfileImage!.path // Store new image path
                      : widget.profile
                          .profilePhotoUrl, // Keep old image if not changed
                  skills: skillsList,
                );
                context
                    .read<EditCollaboratorProfileBloc>()
                    .add(SaveCollaboratorProfile(updatedProfile));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
