// lib/features/profile/screens/blade/lib/features/profile/bloc/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';

class EditProfileScreen extends StatefulWidget {
  final String userId;

  const EditProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileViewBloc>().add(LoadProfile(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: BlocBuilder<ProfileViewBloc, ProfileViewState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            final profile = state.profile;

            // Initialize text controllers with current profile data
            bioController.text = profile.bio ?? '';
            skillsController.text = profile.skills ?? '';

            return Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: bioController,
                      maxLength: 160,
                      decoration: InputDecoration(labelText: "Bio"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bio';
                        } else if (value.length > 160) {
                          return 'Bio cannot exceed 160 characters';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: skillsController,
                      decoration: InputDecoration(labelText: "Skills"),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Dispatch the event to update the profile
                          context.read<ProfileViewBloc>().add(
                                UpdateProfile(
                                  profile.copy(
                                    bio: bioController.text,
                                    skills: skillsController.text,
                                  ),
                                ),
                              );
                          Navigator.pop(context); // Return to previous screen
                        }
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(child: Text('Unable to load profile.'));
        },
      ),
    );
  }
}
