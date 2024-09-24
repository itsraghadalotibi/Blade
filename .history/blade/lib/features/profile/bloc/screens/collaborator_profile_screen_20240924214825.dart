// Path: lib/features/profile/screens/collaborator_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart';
import '../screens/project_idea_card_widget.dart';
import '../repository/project_idea_repository.dart';
import '../src/project_idea_model.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/skill_tag.dart';
import '../../utils/constants/colors.dart'; // Import for Orange color

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

                  if (updatedProfile != null &&
                      updatedProfile is CollaboratorProfileModel) {
                    setState(() {
                      _updatedProfile = updatedProfile;
                    });

                    // Reload the profile data immediately after editing
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
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.profilePhotoUrl != null
                ? NetworkImage(profile.profilePhotoUrl!)
                : const AssetImage('assets/images/user.png') as ImageProvider,
          ),
          const SizedBox(height: 16),

          // Row with Name and Social Media Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${profile.firstName} ${profile.lastName}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(width: 16),

              // GitHub Icon
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.github,
                  color: profile.socialMediaLinks?['GitHub'] != null
                      ? TColors.primary // Use orange for active icons
                      : Colors.grey,
                  size: 24,
                ),
                onPressed: profile.socialMediaLinks?['GitHub'] != null
                    ? () {
                        launch(profile.socialMediaLinks!['GitHub']!);
                      }
                    : null, // Disable button if no link
              ),
              const SizedBox(width: 8),

              // LinkedIn Icon
              IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.linkedin,
                  color: profile.socialMediaLinks?['LinkedIn'] != null
                      ? TColors.primary // Use orange for active icons
                      : Colors.grey,
                  size: 24,
                ),
                onPressed: profile.socialMediaLinks?['LinkedIn'] != null
                    ? () {
                        launch(profile.socialMediaLinks!['LinkedIn']!);
                      }
                    : null, // Disable button if no link
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Skills as Chips (smaller and orange-colored)
          Wrap(
            spacing: 8.0,
            children: profile.skills?.map((skill) {
                  return Chip(
                    label: Text(skill),
                    backgroundColor: TColors.primary, // Use orange for chips
                    labelStyle:
                        const TextStyle(color: Colors.white), // White text
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  );
                }).toList() ??
                [],
          ),
          const SizedBox(height: 16),

          // Bio Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
              const SizedBox(height: 8),
              Text(profile.bio ?? 'No bio available',
                  style: const TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Section (Ideas, Ongoing, Completed)
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
            indicatorColor: TColors.primary, // Use orange for tab indicator
            labelColor: TColors.primary, // Orange for selected tabs
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Ideas'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
          SizedBox(
            height: 300, // Adjust the height of the tab content
            child: TabBarView(
              children: [
                buildProjectIdeasTab(), // Project Ideas content
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
          return const Center(
              child: Text(
            'No project ideas found.',
            style: TextStyle(color: Colors.grey),
          ));
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
