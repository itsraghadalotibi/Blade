import 'package:blade_app/features/announcement/screens/announcement_screen.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/announcement/widgets/skill_tag_widget.dart';
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
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _projectIdeaRepository = ProjectIdeaRepository();
    _futureIdeas = _projectIdeaRepository.fetchIdeasByOwner(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(widget.userId)),
      child: Scaffold(
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, // Dynamic background color
        appBar: AppBar(
          backgroundColor: Theme.of(context)
              .appBarTheme
              .backgroundColor, // Dynamic app bar color
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).iconTheme.color, // Themed icon color
              ),
              onPressed: () async {
                final state = BlocProvider.of<ProfileViewBloc>(context).state;
                if (state is ProfileLoaded &&
                    state.profile is CollaboratorProfileModel) {
                  final profile = _updatedProfile ??
                      state.profile as CollaboratorProfileModel;
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
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .error))); // Use themed error color
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // First Name
                      Text(
                        profile.firstName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      // Last Name
                      Text(
                        profile.lastName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      // GitHub Icon with customized Tooltip
                      Tooltip(
                        message: (profile.socialMediaLinks?['GitHub'] != null &&
                                profile.socialMediaLinks!['GitHub']!.isNotEmpty)
                            ? 'Go to GitHub'
                            : 'No GitHub URL available',
                        textStyle: const TextStyle(
                            color: Colors.white), // Tooltip text color
                        decoration: BoxDecoration(
                          color: Colors.black87, // Tooltip background color
                          borderRadius: BorderRadius.circular(4),
                        ),
                        preferBelow:
                            false, // Ensures tooltip appears above the icon
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.github,
                            color: (profile.socialMediaLinks?['GitHub'] !=
                                        null &&
                                    profile.socialMediaLinks!['GitHub']!
                                        .isNotEmpty)
                                ? TColors
                                    .primary // Always orange for active GitHub URL
                                : Colors.grey, // Gray when no URL is available
                            size: 24,
                          ),
                          padding: const EdgeInsets.all(
                              0), // Remove padding around icon
                          constraints:
                              const BoxConstraints(), // Keep the icon small
                          onPressed: (profile.socialMediaLinks?['GitHub'] !=
                                      null &&
                                  profile
                                      .socialMediaLinks!['GitHub']!.isNotEmpty)
                              ? () {
                                  launch(profile.socialMediaLinks!['GitHub']!);
                                }
                              : null, // Disable button if no link
                        ),
                      ),
                      const SizedBox(width: 4),
// LinkedIn Icon with customized Tooltip
                      Tooltip(
                        message:
                            (profile.socialMediaLinks?['LinkedIn'] != null &&
                                    profile.socialMediaLinks!['LinkedIn']!
                                        .isNotEmpty)
                                ? 'Go to LinkedIn'
                                : 'No LinkedIn URL available',
                        textStyle: const TextStyle(
                            color: Colors.white), // Tooltip text color
                        decoration: BoxDecoration(
                          color: Colors.black87, // Tooltip background color
                          borderRadius: BorderRadius.circular(4),
                        ),
                        preferBelow:
                            false, // Ensures tooltip appears above the icon
                        child: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.linkedin,
                            color: (profile.socialMediaLinks?['LinkedIn'] !=
                                        null &&
                                    profile.socialMediaLinks!['LinkedIn']!
                                        .isNotEmpty)
                                ? TColors
                                    .primary // Always orange for active LinkedIn URL
                                : Colors.grey, // Gray when no URL is available
                            size: 24,
                          ),
                          padding: const EdgeInsets.all(
                              0), // Remove padding around icon
                          constraints:
                              const BoxConstraints(), // Keep the icon small
                          onPressed: (profile.socialMediaLinks?['LinkedIn'] !=
                                      null &&
                                  profile.socialMediaLinks!['LinkedIn']!
                                      .isNotEmpty)
                              ? () {
                                  launch(
                                      profile.socialMediaLinks!['LinkedIn']!);
                                }
                              : null, // Disable button if no link
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: profile.skills?.map((skill) {
                          return SkillTagWidget(
                            skills: [skill], // Pass each skill as a list
                          );
                        }).toList() ??
                        [],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        style: Theme.of(context).textTheme.bodyMedium,
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
      body: buildTabBarSection(),
    );
  }

  Widget buildTabBarSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
