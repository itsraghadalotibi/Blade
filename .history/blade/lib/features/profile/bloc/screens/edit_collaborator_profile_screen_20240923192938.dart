import 'dart:io';
import 'package:blade_app/features/authentication/bloc/authentication_state.dart';
import 'package:blade_app/utils/constants/sizes.dart';
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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _githubController;
  late TextEditingController _linkedInController;

  File? _newProfileImage;
  final ImagePicker _picker = ImagePicker();

  List<String> _selectedSkills = [];

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _githubController = TextEditingController(
        text: widget.profile.socialMediaLinks?['GitHub'] ?? '');
    _linkedInController = TextEditingController(
        text: widget.profile.socialMediaLinks?['LinkedIn'] ?? '');
    _selectedSkills = widget.profile.skills ?? [];
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
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
          if (state is CollaboratorProfileUpdateSuccess) {
            Navigator.pop(context, state.updatedProfile);
          } else if (state is CollaboratorProfileUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.md), // Consistent padding
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _newProfileImage != null
                        ? FileImage(_newProfileImage!)
                        : (widget.profile.profilePhotoUrl != null
                                ? NetworkImage(widget.profile.profilePhotoUrl!)
                                : const AssetImage('assets/images/user.png'))
                            as ImageProvider,
                    child: const Icon(Icons.camera_alt, size: 30),
                  ),
                ),
                const SizedBox(height: TSizes.md),

                // First Name Field
                CustomTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                ),
                const SizedBox(height: TSizes.md),

                // Last Name Field
                CustomTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                ),
                const SizedBox(height: TSizes.md),

                // Bio Field
                CustomTextField(
                  label: 'Bio',
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 300,
                ),
                const SizedBox(height: TSizes.md),

                // Skills Dropdown
                BlocBuilder<EditCollaboratorProfileBloc,
                    EditCollaboratorProfileState>(
                  builder: (context, state) {
                    if (state is SkillsLoaded) {
                      return DropdownButtonFormField<String>(
                        items: (state as SkillsLoaded)
                            .availableSkills
                            .map((skill) => DropdownMenuItem<String>(
                                  value: skill,
                                  child: Text(skill),
                                ))
                            .toList(),
                        onChanged: (selected) {
                          setState(() {
                            _selectedSkills.add(selected!);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Skills',
                        ),
                      );
                    } else if (state is SkillsLoading) {
                      return const CircularProgressIndicator();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: TSizes.md),

                // GitHub Link
                CustomTextField(
                  label: 'GitHub Profile Link (Optional)',
                  controller: _githubController,
                ),
                const SizedBox(height: TSizes.md),

                // LinkedIn Link
                CustomTextField(
                  label: 'LinkedIn Profile Link (Optional)',
                  controller: _linkedInController,
                ),
                const SizedBox(height: TSizes.md),

                // Save Button
                CustomButton(
                  text: 'Save',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
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
                          'GitHub': _githubController.text.trim(),
                          'LinkedIn': _linkedInController.text.trim(),
                        },
                      );
                      context
                          .read<EditCollaboratorProfileBloc>()
                          .add(SaveCollaboratorProfile(updatedProfile));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
