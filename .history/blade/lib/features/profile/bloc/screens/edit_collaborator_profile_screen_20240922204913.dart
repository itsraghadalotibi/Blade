// Path: lib/features/profile/screens/collaborator_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart'; // Import the edit screen
import '../screens/project_idea_card_widget.dart';
import '../repository/project_idea_repository.dart';
import '../src/project_idea_model.dart';
import '../bloc/edit_collaborator_profile_bloc.dart'; // Import the edit profile bloc

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
                // Navigate to the edit screen with the EditCollaboratorProfileBloc
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => EditCollaboratorProfileBloc(
                        profileRepository: context.read(),
                      ),
                      child: EditCollaboratorProfileScreen(
                        profile: _updatedProfile ??
                            CollaboratorProfileModel(
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

                // After returning from the edit screen, check if there is an updated profile
                if (updatedProfile != null &&
                    updatedProfile is CollaboratorProfileModel) {
                  setState(() {
                    _updatedProfile = updatedProfile;
                  });

                  // Emit a new event to refresh the profile data
                  context
                      .read<ProfileViewBloc>()
                      .add(LoadProfile(widget.userId));
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
              } else if (state is ProfileLoaded &&
                  state.profile is CollaboratorProfileModel) {
                final profile = state.profile as CollaboratorProfileModel;
                _updatedProfile = profile; // Store the loaded profile
                return buildCollaboratorProfile(profile);
              } else if (state is ProfileError) {
                return Center(
                  child: Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red)),
                );
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
            backgroundImage: NetworkImage(
                profile.profilePhotoUrl ?? 'assets/images/user.png'),
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
          DefaultTabController(
            length: 3,
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
                  height: 300,
                  child: TabBarView(
                    children: [
                      buildProjectIdeasTab(), // Project Ideas tab
                      Text('Ongoing Projects content here...'),
                      Text('Completed Projects content here...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProjectIdeasTab() {
    return FutureBuilder<List<Idea>>(
      future: _futureIdeas,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading ideas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No project ideas found.'));
        }

        final ideas = snapshot.data!;

        return ListView.builder(
          itemCount: ideas.length,
          itemBuilder: (context, index) {
            final idea = ideas[index];
            return ProjectIdeaCardWidget(
              idea: idea,
              repository: _projectIdeaRepository,
            );
          },
        );
      },
    );
  }
}
