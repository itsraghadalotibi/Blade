// Path: features/profile/screens/edit_collaborator_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/edit_collaborator_profile_event.dart';
import '../bloc/edit_collaborator_profile_state.dart';
import '../src/collaborator_profile_model.dart';

class EditCollaboratorProfileScreen extends StatelessWidget {
  final CollaboratorProfileModel profile;

  const EditCollaboratorProfileScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Collaborator Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) =>
              EditCollaboratorProfileBloc(profileRepository: context.read()),
          child: EditCollaboratorProfileForm(profile: profile),
        ),
      ),
    );
  }
}

class EditCollaboratorProfileForm extends StatefulWidget {
  final CollaboratorProfileModel profile;

  const EditCollaboratorProfileForm({Key? key, required this.profile})
      : super(key: key);

  @override
  _EditCollaboratorProfileFormState createState() =>
      _EditCollaboratorProfileFormState();
}

class _EditCollaboratorProfileFormState
    extends State<EditCollaboratorProfileForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);

    // Combine skills list into a comma-separated string
    _skillsController = TextEditingController(
      text: widget.profile.skills?.join(', ') ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditCollaboratorProfileBloc,
        EditCollaboratorProfileState>(
      listener: (context, state) {
        if (state is CollaboratorProfileUpdateSuccess) {
          Navigator.pop(context); // Go back after successful update
        } else if (state is CollaboratorProfileUpdateFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      },
      child: Column(
        children: [
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
                profilePhotoUrl: widget.profile.profilePhotoUrl,
                skills: skillsList, // Save as List<String>
              );
              context
                  .read<EditCollaboratorProfileBloc>()
                  .add(SaveCollaboratorProfile(updatedProfile));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
