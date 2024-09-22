// Path: lib/features/profile/screens/collaborator_profile_screen.dart

import 'dart:io';
// Path: lib/features/profile/screens/collaborator_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart';
import 'dart:io';

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;

  const CollaboratorProfileScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _CollaboratorProfileScreenState createState() =>
      _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen> {
  CollaboratorProfileModel? _updatedProfile;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(widget.userId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Collaborator Profile'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final state = BlocProvider.of<ProfileViewBloc>(context).state;
                if (state is ProfileLoaded &&
                    state.profile is CollaboratorProfileModel) {
                  final profile = _updatedProfile ??
                      state.profile as CollaboratorProfileModel;

                  // Navigate to EditCollaboratorProfileScreen with BlocProvider
                  final updatedProfile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => EditCollaboratorProfileBloc(
                          profileRepository: context.read(),
                        ),
                        child: EditCollaboratorProfileScreen(profile: profile),
                      ),
                    ),
                  );
                  if (updatedProfile != null) {
                    setState(() {
                      _updatedProfile = updatedProfile;
                    });
                  }
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ProfileViewBloc, ProfileViewState>(
            builder: (context, state) {
              final profile = _updatedProfile ??
                  (state is ProfileLoaded &&
                          state.profile is CollaboratorProfileModel
                      ? state.profile as CollaboratorProfileModel
                      : null);

              if (profile != null) {
                return buildCollaboratorProfile(profile);
              } else if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(
                    child: Text('Error: ${state.message}',
                        style: const TextStyle(color: Colors.red)));
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
            backgroundImage: profile.profilePhotoUrl != null
                ? FileImage(File(profile.profilePhotoUrl!))
                : AssetImage('assets/images/user.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: profile.skills?.map((skill) {
                  return Chip(label: Text(skill), backgroundColor: Colors.red);
                }).toList() ??
                [],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(profile.bio ?? 'No bio available',
                  style: const TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          buildTabBarSection(),
        ],
      ),
    );
  }

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 3, // Three tabs: Project Ideas, Ongoing, and Completed
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Project Ideas'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
          SizedBox(
            height: 300, // Adjust the height of the tab content
            child: TabBarView(
              children: [
                Center(child: Text('Project Ideas content here...')),
                Center(child: Text('Ongoing Projects content here...')),
                Center(child: Text('Completed Projects content here...')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
