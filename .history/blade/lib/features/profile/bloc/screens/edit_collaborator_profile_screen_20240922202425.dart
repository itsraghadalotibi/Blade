// Path: lib/features/profile/screens/edit_collaborator_profile_screen.dart

import 'dart:io'; // For File handling
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Collaborator Profile')),
      body: BlocListener<EditCollaboratorProfileBloc,
          EditCollaboratorProfileState>(
        listener: (context, state) {
          if (state is CollaboratorProfileUpdateSuccess) {
            // Return the updated profile to the previous screen
            Navigator.pop(context, state.updatedProfile);
          } else if (state is CollaboratorProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display profile photo or default image
                GestureDetector(
                  onTap: _pickImage, // Open gallery on tap
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _newProfileImage != null
                        ? FileImage(
                            _newProfileImage!) // Show the selected image
                        : AssetImage('assets/images/user.png')
                            as ImageProvider, // Default image from assets
                    child:
                        const Icon(Icons.camera_alt, size: 30), // Camera icon
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
                  decoration: const InputDecoration(
                    labelText: 'Skills (comma separated)',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  // Inside the CollaboratorProfileScreen
onPressed: () async {
  // Navigate to the edit screen and wait for the result (updated profile)
  final updatedProfile = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => EditCollaboratorProfileBloc(
          profileRepository: context.read(),
        ),
        child: EditCollaboratorProfileScreen(
          profile: _updatedProfile ?? CollaboratorProfileModel(
            uid: widget.userId,
            firstName: '',
            lastName: '',
            bio: '',
            profilePhotoUrl: '',
            skills: [],
          ),
        ),
      ),
    ),
  );

  // If the profile is updated, reload it immediately in the UI
  if (updatedProfile != null && updatedProfile is CollaboratorProfileModel) {
    setState(() {
      _updatedProfile = updatedProfile;
    });

    // Optionally trigger a profile reload from the repository, or just update UI directly
    context.read<ProfileViewBloc>().add(LoadProfile(widget.userId));
  }
}
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
