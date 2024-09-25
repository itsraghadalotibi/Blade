import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Image picker
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/edit_collaborator_profile_event.dart';
import '../bloc/edit_collaborator_profile_state.dart';
import '../src/collaborator_profile_model.dart';
import '../../../utils/theme/custom_themes/multi_select_dialog_theme.dart';

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
  late TextEditingController _githubController;
  late TextEditingController _linkedInController;

  File? _newProfileImage; // Store the new profile image
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  // Multi-select dropdown for skills
  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _githubController =
        TextEditingController(text: widget.profile.socialMediaLinks['GitHub']);
    _linkedInController = TextEditingController(
        text: widget.profile.socialMediaLinks['LinkedIn']);
    _selectedSkills = widget.profile.skills ?? [];
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
            Navigator.pop(context, state.updatedProfile);
          } else if (state is CollaboratorProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Display profile photo or default image
              GestureDetector(
                onTap: _pickImage, // Open gallery on tap
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!) // Show the selected image
                      : AssetImage('assets/images/user.png')
                          as ImageProvider, // Default image from assets
                  child: const Icon(Icons.camera_alt, size: 30), // Camera icon
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_firstNameController, 'First Name'),
              _buildTextField(_lastNameController, 'Last Name'),
              _buildTextField(_bioController, 'Bio'),
              const SizedBox(height: 16),

              // Skills multi-select dropdown
              BlocBuilder<EditCollaboratorProfileBloc,
                  EditCollaboratorProfileState>(
                builder: (context, state) {
                  if (state is SkillsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SkillsLoaded) {
                    final List<MultiSelectItem<String>> skillsItems = state
                        .availableSkills
                        .map((skill) => MultiSelectItem<String>(skill, skill))
                        .toList();

                    return TMultiSelectDialogTheme.lightMultiSelectDialogField(
                      items: skillsItems,
                      selectedItems: _selectedSkills,
                      onConfirm: (results) {
                        setState(() {
                          _selectedSkills = results;
                        });
                      },
                      title: 'Skills',
                      buttonText: 'Select Skills (Optional)',
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                  _githubController, 'GitHub Profile Link (Optional)'),
              _buildTextField(
                  _linkedInController, 'LinkedIn Profile Link (Optional)'),
              const SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  final updatedProfile = CollaboratorProfileModel(
                    uid: widget.profile.uid,
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    bio: _bioController.text,
                    profilePhotoUrl: _newProfileImage != null
                        ? _newProfileImage!.path
                        : widget.profile.profilePhotoUrl,
                    skills: _selectedSkills,
                    socialMediaLinks: {
                      'GitHub': _githubController.text,
                      'LinkedIn': _linkedInController.text,
                    },
                  );

                  // Trigger the SaveCollaboratorProfile event
                  context.read<EditCollaboratorProfileBloc>().add(
                        SaveCollaboratorProfile(updatedProfile),
                      );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}
