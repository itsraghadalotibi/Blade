// Path: features/profile/screens/edit_supporter_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_supporter_profile_bloc.dart';
import '../bloc/edit_supporter_profile_event.dart';
import '../bloc/edit_supporter_profile_state.dart';
import '../src/supporter_profile_model.dart';

class EditSupporterProfileScreen extends StatelessWidget {
  final SupporterProfileModel profile;

  const EditSupporterProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Supporter Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) =>
              EditSupporterProfileBloc(profileRepository: context.read()),
          child: EditSupporterProfileForm(profile: profile),
        ),
      ),
    );
  }
}

class EditSupporterProfileForm extends StatefulWidget {
  final SupporterProfileModel profile;

  const EditSupporterProfileForm({super.key, required this.profile});

  @override
  _EditSupporterProfileFormState createState() =>
      _EditSupporterProfileFormState(); // Add this line
}

class _EditSupporterProfileFormState extends State<EditSupporterProfileForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditSupporterProfileBloc, EditSupporterProfileState>(
      listener: (context, state) {
        if (state is SupporterProfileUpdateSuccess) {
          Navigator.pop(context); // Go back after successful update
        } else if (state is SupporterProfileUpdateFailure) {
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
          ElevatedButton(
            onPressed: () {
              final updatedProfile = SupporterProfileModel(
                uid: widget.profile.uid,
                firstName: _firstNameController.text,
                lastName: _lastNameController.text,
                email: widget.profile.email,
                bio: _bioController.text,
                profilePhotoUrl: widget.profile.profilePhotoUrl,
              );
              context
                  .read<EditSupporterProfileBloc>()
                  .add(SaveSupporterProfile(updatedProfile));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
