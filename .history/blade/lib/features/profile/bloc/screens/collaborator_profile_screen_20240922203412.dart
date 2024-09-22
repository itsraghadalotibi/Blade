// Path: lib/features/profile/screens/collaborator_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart';
import '../screens/project_idea_card_widget.dart';
import '../repository/project_idea_repository.dart';
import '../src/project_idea_model.dart';

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;

  const CollaboratorProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _CollaboratorProfileScreenState createState() => _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen> {
  CollaboratorProfileModel? _updatedProfile;
  late ProjectIdeaRepository _projectIdeaRepository;
  Future<List<Idea>>? _futureIdeas;

  @override
  void initState() {
    super.initState();
    _projectIdeaRepository = ProjectIdeaRepository();
    _futureIdeas = _projectIdeaRepository.fetchIdeasByOwner(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())..add(LoadProfile(widget.userId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Collaborator Profile'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Navigate to the edit screen and wait for the result
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => EditCollaboratorProfileBloc(profileRepository: context.read()),
                      child: EditCollaboratorProfileScreen(profile: _updatedProfile ?? CollaboratorProfileModel(
                        uid: widget.userId,
                        firstName: '',
                        lastName: '',
                        bio: '',
                        profilePhotoUrl: '',
                        skills: [],
                      )),
                    ),
                  ),
                );

                // Update the UI with the new profile
                if (updatedProfile != null && updatedProfile is CollaboratorProfileModel) {
                  setState(() {
                    _updatedProfile = updatedProfile;
                  });
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ProfileViewBloc, ProfileViewState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded && state.profile is CollaboratorProfileModel) {
                final profile = state.profile as CollaboratorProfileModel;
                _updatedProfile = profile; // Update the profile state
                return buildCollaboratorProfile(profile);
              } else if (state is ProfileError) {
                return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text('Unable to load profile.'));
            },
          ),
        ),
      ),
    );
  }

  Widget buildCollaboratorProfile(CollaboratorProfileModel profile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profile.profilePhotoUrl ?? 'assets/images/user.png'),
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: (profile.skills ?? []).map((skill) {
              return Chip(label: Text(skill), backgroundColor: Colors.red);
            }).toList(),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(fontSize: 18,