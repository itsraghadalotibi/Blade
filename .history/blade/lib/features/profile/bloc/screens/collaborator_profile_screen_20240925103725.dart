import 'package:blade_app/features/announcement/screens/announcement_screen.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/newPost/screens/backgroundPost.dart';
import 'package:blade_app/utils/constants/Navigation/profile.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart';
import '../screens/project_idea_card_widget.dart';
import '../repository/project_idea_repository.dart';
import '../src/project_idea_model.dart';
import 'package:blade_app/home_screen.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart' as settings;

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;

  const CollaboratorProfileScreen({super.key, required this.userId});

  @override
  _CollaboratorProfileScreenState createState() =>
      _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen>
    with SingleTickerProviderStateMixin {
  CollaboratorProfileModel? _updatedProfile;
  late ProjectIdeaRepository _projectIdeaRepository;
  Future<List<Idea>>? _futureIdeas;
  late TabController _tabController; // TabController for managing tab view

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Initialize TabController
    _projectIdeaRepository = ProjectIdeaRepository(); // Fetch project ideas
    _futureIdeas = _projectIdeaRepository.fetchIdeasByOwner(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController when no longer in use
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(widget.userId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false, // Removes the back button
          actions: [
            IconButton(
              icon: const Icon(Icons.edit,
                  color: Colors.orange), // Edit icon in orange
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
        body: BlocBuilder<ProfileViewBloc, ProfileViewState>(
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
    );
  }

  Widget buildCollaboratorProfile(CollaboratorProfileModel profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.profilePhotoUrl != null
                        ? NetworkImage(profile.profilePhotoUrl!)
                        : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
                  // Row for first and last name with social media icons
                  // Row for first and last name with social media icons
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the entire row
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Align items vertically centered
                    children: [
                      // First Name
                      Text(
                        profile.firstName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                          width:
                              8), // Add more space between the first and last name

                      // Last Name
                      Text(
                        profile.lastName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                          width:
                              16), // Add space between the last name and icons

                      // GitHub Icon
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.github,
                          color: profile.socialMediaLinks?['GitHub'] != null
                              ? TColors.primary // Use orange for active icons
                              : Colors.grey,
                          size: 24,
                        ),
                        padding: const EdgeInsets.all(
                            0), // Remove default padding around the icon
                        constraints:
                            const BoxConstraints(), // Make sure the icon button stays small
                        onPressed: profile.socialMediaLinks?['GitHub'] != null
                            ? () {
                                launch(profile.socialMediaLinks!['GitHub']!);
                              }
                            : null, // Disable button if no link
                      ),
                      // Removed the space between GitHub and LinkedIn
                      const SizedBox(width: 1),
                      // LinkedIn Icon (now placed right next to GitHub)
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.linkedin,
                          color: profile.socialMediaLinks?['LinkedIn'] != null
                              ? TColors.primary // Use orange for active icons
                              : Colors.grey,
                          size: 24,
                        ),
                        padding: const EdgeInsets.all(
                            0), // Remove default padding around the icon
                        constraints:
                            const BoxConstraints(), // Make sure the icon button stays small
                        onPressed: profile.socialMediaLinks?['LinkedIn'] != null
                            ? () {
                                launch(profile.socialMediaLinks!['LinkedIn']!);
                              }
                            : null, // Disable button if no link
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    children: profile.skills?.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor: TColors.primary,
                            labelStyle: const TextStyle(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          );
                        }).toList() ??
                        [],
                  ),
                  const SizedBox(height: 16),
                  // About Section (Now centered properly)
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center aligned
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.bio ?? 'No bio available',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ]),
          ),
        ];
      },
      body:
          buildTabBarSection(), // The tab bar and its content scrolls together
    );
  }

  Widget buildTabBarSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: TColors.primary,
          labelColor: TColors.primary,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(text: 'Ideas'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              buildProjectIdeasTab(),
              const Center(child: Text('Ongoing Projects content here...')),
              const Center(child: Text('Completed Projects content here...')),
            ],
          ),
        ),
      ],
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
