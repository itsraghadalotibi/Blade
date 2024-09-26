import 'package:blade_app/features/announcement/screens/announcement_screen.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/announcement/widgets/skill_tag_widget.dart';
import 'package:blade_app/features/newPost/screens/backgroundPost.dart';
import 'package:blade_app/features/profile/bloc/screens/edit_collaborator_profile_screen.dart';
import 'package:blade_app/utils/constants/Navigation/profile.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/project_idea_card_widget.dart';
import '../repository/project_idea_repository.dart';
import '../src/project_idea_model.dart';
import 'package:blade_app/home_screen.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart' as settings;

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;
  final bool showBackButton; // Add this parameter

  const CollaboratorProfileScreen({
    super.key,
    required this.userId,
    this.showBackButton = false, // Default value is false
  });

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

  // Variables for bio expansion
  bool isBioExpanded = false;
  static const int maxBioLines = 3; // Limit bio to 3 lines initially
  String? _currentUserId; // Variable to hold the authenticated user's ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _projectIdeaRepository = ProjectIdeaRepository();
    _futureIdeas = _projectIdeaRepository.fetchIdeasByOwner(widget.userId);

    // Fetch the authenticated user's ID from Firebase
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if the logged-in user is the profile owner
    final bool isOwner = _currentUserId == widget.userId;

    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(widget.userId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          automaticallyImplyLeading:
              widget.showBackButton, // Use showBackButton flag
          actions: isOwner
              ? [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context)
                          .iconTheme
                          .color, // Themed icon color
                    ),
                    onPressed: () async {
                      final state =
                          BlocProvider.of<ProfileViewBloc>(context).state;
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
                              child: EditCollaboratorProfileScreen(
                                  profile: profile),
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
                ]
              : null, // Hide edit button if not the owner
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
                          color: Theme.of(context).colorScheme.error)));
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

                  // Name and Social Icons Section
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            profile.firstName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            profile.lastName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Tooltip(
                            message:
                                (profile.socialMediaLinks?['GitHub'] != null &&
                                        profile.socialMediaLinks!['GitHub']!
                                            .isNotEmpty)
                                    ? 'Go to GitHub'
                                    : 'No GitHub URL available',
                            textStyle: const TextStyle(color: Colors.white),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            preferBelow: false,
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.github,
                                color: (profile.socialMediaLinks?['GitHub'] !=
                                            null &&
                                        profile.socialMediaLinks!['GitHub']!
                                            .isNotEmpty)
                                    ? TColors.primary
                                    : Colors.grey,
                                size: 24,
                              ),
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              onPressed: (profile.socialMediaLinks?['GitHub'] !=
                                          null &&
                                      profile.socialMediaLinks!['GitHub']!
                                          .isNotEmpty)
                                  ? () {
                                      launch(
                                          profile.socialMediaLinks!['GitHub']!);
                                    }
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Tooltip(
                            message: (profile.socialMediaLinks?['LinkedIn'] !=
                                        null &&
                                    profile.socialMediaLinks!['LinkedIn']!
                                        .isNotEmpty)
                                ? 'Go to LinkedIn'
                                : 'No LinkedIn URL available',
                            textStyle: const TextStyle(color: Colors.white),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            preferBelow: false,
                            child: IconButton(
                              icon: FaIcon(
                                FontAwesomeIcons.linkedin,
                                color: (profile.socialMediaLinks?['LinkedIn'] !=
                                            null &&
                                        profile.socialMediaLinks!['LinkedIn']!
                                            .isNotEmpty)
                                    ? TColors.primary
                                    : Colors.grey,
                                size: 24,
                              ),
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                              onPressed:
                                  (profile.socialMediaLinks?['LinkedIn'] !=
                                              null &&
                                          profile.socialMediaLinks!['LinkedIn']!
                                              .isNotEmpty)
                                      ? () {
                                          launch(profile
                                              .socialMediaLinks!['LinkedIn']!);
                                        }
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Skills section with scrolling and limited height (max 2 rows)
                  SizedBox(
                    height: 80, // Approximate height for two rows of chips
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: profile.skills?.map((skill) {
                              return SkillTagWidget(
                                skills: [skill],
                              );
                            }).toList() ??
                            [],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About Section with Show More/Show Less
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.primary),
                      ),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          // Measure if the bio text exceeds the max lines
                          final span = TextSpan(
                            text: profile.bio ?? 'No bio available',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );

                          final tp = TextPainter(
                            text: span,
                            maxLines: maxBioLines,
                            textAlign: TextAlign.left,
                            textDirection: TextDirection.ltr,
                          );

                          tp.layout(maxWidth: constraints.maxWidth);
                          final exceedsMaxLines = tp.didExceedMaxLines;

                          return Column(
                            children: [
                              Text(
                                profile.bio ?? 'No bio available',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: isBioExpanded ? null : maxBioLines,
                                overflow: isBioExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              if (exceedsMaxLines)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isBioExpanded = !isBioExpanded;
                                    });
                                  },
                                  child: Text(
                                    isBioExpanded ? 'Show less' : 'Show more',
                                    style: const TextStyle(
                                      color: TColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
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
