import 'dart:io';
import 'package:blade_app/features/authentication/bloc/authentication_event.dart'
    as auth;
import 'package:blade_app/features/authentication/bloc/authentication_state.dart'
    as auth_state;
import 'package:blade_app/utils/constants/colors.dart';
import 'package:blade_app/utils/theme/custom_themes/multi_select_dialog_theme.dart';
import 'package:blade_app/widgets/custom_button.dart';
import 'package:blade_app/widgets/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
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
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _githubController = TextEditingController(
        text: widget.profile.socialMediaLinks?['GitHub'] ?? '');
    _linkedInController = TextEditingController(
        text: widget.profile.socialMediaLinks?['LinkedIn'] ?? '');
    _selectedSkills = widget.profile.skills ?? [];

    // Fetch skills from the BLoC
    context.read<EditCollaboratorProfileBloc>().add(FetchSkills());
  }

  // Image picker function
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
      });
    }
  }

  // Save button functionality
  void _onSaveButtonPressed() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = CollaboratorProfileModel(
        uid: widget.profile.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _selectedSkills,
        profilePhotoUrl:
            _newProfileImage?.path ?? widget.profile.profilePhotoUrl,
        socialMediaLinks: {
          'GitHub': _githubController.text.trim(),
          'LinkedIn': _linkedInController.text.trim(),
        },
      );
      context
          .read<EditCollaboratorProfileBloc>()
          .add(SaveCollaboratorProfile(updatedProfile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collaborator Profile'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
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
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image with green shadow
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.greenAccent, // Green shadow
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: _newProfileImage != null
                              ? FileImage(_newProfileImage!)
                              : NetworkImage(widget.profile.profilePhotoUrl ??
                                      defaultProfileImageUrl)
                                  as ImageProvider<Object>?,
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

                // First Name Field
                CustomTextField(
                  label: 'First Name',
                  controller: _firstNameController,
                ),
                const SizedBox(height: 16),

                // Last Name Field
                CustomTextField(
                  label: 'Last Name',
                  controller: _lastNameController,
                ),
                const SizedBox(height: 16),

                // Bio Field
                CustomTextField(
                  label: 'Bio',
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 300,
                ),
                const SizedBox(height: 16),

                // Skills Dropdown Menu and Chips
                BlocBuilder<EditCollaboratorProfileBloc,
                    EditCollaboratorProfileState>(
                  builder: (context, state) {
                    if (state is SkillsLoaded) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Skills Dropdown Menu without displaying blue chips
                          TMultiSelectDialogTheme.lightMultiSelectDialogField(
                            items: state.availableSkills
                                .map((skill) => MultiSelectItem(skill, skill))
                                .toList(),
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

                          // Display selected skills as orange chips
                          Wrap(
                            spacing: 8.0,
                            children: _selectedSkills.map((skill) {
                              return Chip(
                                label: Text(skill),
                                backgroundColor:
                                    TColors.primary, // Orange color
                                deleteIconColor: Colors.white,
                                onDeleted: () {
                                  setState(() {
                                    _selectedSkills.remove(skill);
                                  });
                                },
                              );
                            }).toList(),
                          ),
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

                // GitHub Field
                CustomTextField(
                  label: 'GitHub Profile Link (Optional)',
                  controller: _githubController,
                ),
                const SizedBox(height: 16),

                // LinkedIn Field
                CustomTextField(
                  label: 'LinkedIn Profile Link (Optional)',
                  controller: _linkedInController,
                ),
                const SizedBox(height: 16),

                // Save Button
                CustomButton(
                  text: 'Save',
                  onPressed: _onSaveButtonPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
