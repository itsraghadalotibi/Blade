// Path: lib/features/profile/screens/collaborator_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/collaborator_profile_model.dart';
import '../widgets/project_idea_card_widget.dart';
import '../src/project_idea_repository.dart';
import '../src/project_idea_model.dart';

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
  Future<List<Idea>>? _futureIdeas; // This will store the user's project ideas

  @override
  void initState() {
    super.initState();
    _projectIdeaRepository = ProjectIdeaRepository();
    // Fetch project ideas for the user
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
                // Navigate to the edit screen (implementation not included here)
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
                return buildCollaboratorProfile(profile);
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
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    profile.profilePhotoUrl ?? 'https://placeholder.com'),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.edit, size: 16),
                ),
              ),
            ],
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
            children: profile.skills?.split(',').map((skill) {
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

          // Tabs for Projects (Ideas, Ongoing, Completed)
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

  // Fetch and display project ideas under the "Project Ideas" tab
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
