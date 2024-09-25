// Path: lib/features/profile/screens/collaborator_profile_screen.dart

import 'package:blade_app/features/profile/bloc/bloc/edit_collaborator_profile_bloc.dart';
import 'package:blade_app/features/profile/bloc/screens/edit_collaborator_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../repository/project_idea_repository.dart';
import '../screens/project_idea_card_widget.dart';
import '../src/project_idea_model.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/skill_tag.dart'; // Assuming this file contains the Skill Chips

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;

  const CollaboratorProfileScreen({super.key, required this.userId});

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
                final state = BlocProvider.of<ProfileViewBloc>(context).state;
                if (state is ProfileLoaded &&
                    state.profile is CollaboratorProfileModel) {
                  final profile = _updatedProfile ??
                      state.profile as CollaboratorProfileModel;

                  // Navigate to EditCollaboratorProfileScreen
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

                  if (updatedProfile != null &&
                      updatedProfile is CollaboratorProfileModel) {
                    setState(() {
                      _updatedProfile = updatedProfile;
                    });
                    context
                        .read<ProfileViewBloc>()
                        .add(LoadProfile(widget.userId));
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
          // Profile Photo
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.profilePhotoUrl != null
                ? NetworkImage(profile.profilePhotoUrl!)
                : const AssetImage('assets/images/user.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // GitHub and LinkedIn Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSocialIcon(profile.socialMediaLinks?['GitHub'], 'GitHub'),
              const SizedBox(width: 10),
              buildSocialIcon(
                  profile.socialMediaLinks?['LinkedIn'], 'LinkedIn'),
            ],
          ),
          const SizedBox(height: 16),

          // Skills
          Wrap(
            spacing: 8.0,
            children: profile.skills?.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: Colors.orange,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList() ??
                [],
          ),
          const SizedBox(height: 16),

          // About Section
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

          // Projects Tab Section
          buildTabBarSection(),
        ],
      ),
    );
  }

  // Method to build the social media icon
  Widget buildSocialIcon(String? url, String platform) {
    bool hasUrl = url != null && url.isNotEmpty;
    IconData iconData = platform == 'GitHub'
        ? Icons.code // GitHub icon
        : Icons.business_center; // LinkedIn icon

    return IconButton(
      icon: Icon(
        iconData,
        color: hasUrl ? Colors.white : Colors.grey,
        size: 30,
      ),
      onPressed: hasUrl ? () => _launchURL(url!) : null,
    );
  }

  // Launch URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Ideas'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                buildProjectIdeasTab(),
                const Center(child: Text('Ongoing Projects content here...')),
                const Center(child: Text('Completed Projects content here...')),
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
