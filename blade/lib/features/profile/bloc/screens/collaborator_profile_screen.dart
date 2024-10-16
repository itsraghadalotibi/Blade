import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/announcement/widgets/skill_tag_widget.dart';
import 'package:blade_app/features/profile/bloc/screens/edit_collaborator_profile_screen.dart';
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

class CollaboratorProfileScreen extends StatefulWidget {
  final String userId;
  final bool showBackButton;

  const CollaboratorProfileScreen({
    super.key,
    required this.userId,
    this.showBackButton = false,
  });

  @override
  _CollaboratorProfileScreenState createState() =>
      _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen>
    with SingleTickerProviderStateMixin {
  CollaboratorProfileModel? _updatedProfile;
  late ProjectIdeaRepository _projectIdeaRepository;
  late AnnouncementRepository _announcementRepository;
  late TabController _tabController;

  // Variables for bio expansion
  bool isBioExpanded = false;
  static const int maxBioLines = 3; // Limit bio to 3 lines initially
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _projectIdeaRepository = ProjectIdeaRepository();
    _announcementRepository = AnnouncementRepository();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          automaticallyImplyLeading: widget.showBackButton,
          actions: isOwner
              ? [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).iconTheme.color,
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
              : null,
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
                    radius: 70,
                    backgroundImage: profile.profilePhotoUrl != null &&
                            profile.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(profile.profilePhotoUrl!)
                        : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),
// Name and Social Icons Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _limitText(
                            '${profile.firstName} ${profile.lastName}', 20),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8), // Space between name and icons

                      // Social Media Links (GitHub and LinkedIn) next to the name
                      Row(
                        children: [
                          // GitHub Icon
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.github,
                              color: profile.socialMediaLinks?['GitHub']
                                          ?.isNotEmpty ==
                                      true
                                  ? TColors.primary
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              final githubUrl =
                                  profile.socialMediaLinks?['GitHub'];
                              if (githubUrl != null && githubUrl.isNotEmpty) {
                                final uri = Uri.parse(githubUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              }
                            },
                          ),
                          const SizedBox(
                              width: 4), // Reduce the width between icons here

                          // LinkedIn Icon
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.linkedin,
                              color: profile.socialMediaLinks?['LinkedIn']
                                          ?.isNotEmpty ==
                                      true
                                  ? TColors.primary
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              final linkedinUrl =
                                  profile.socialMediaLinks?['LinkedIn'];
                              if (linkedinUrl != null &&
                                  linkedinUrl.isNotEmpty) {
                                final uri = Uri.parse(linkedinUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Skills Chips (if available)
                  if (profile.skills != null && profile.skills!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24), // Add horizontal padding
                      child: SizedBox(
                        height: 80,
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: profile.skills!.map((skill) {
                              return SkillTagWidget(skills: [skill]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // About Section with Show More/Show Less
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0), // Add padding on both sides
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      style:
                                          const TextStyle(color: TColors.info),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
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
              buildProjectTab("open"), // Open ideas where user is the owner
              buildProjectTab(
                  "ongoing"), // Ongoing projects where user is a member or owner
              buildProjectTab(
                  "completed"), // Completed projects where user is a member or owner
            ],
          ),
        ),
      ],
    );
  }


  Widget buildProjectTab(String status) {
    return FutureBuilder<List<Idea>>(
      future: _projectIdeaRepository.fetchIdeasByOwner(
          widget.userId, status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading projects: ${snapshot.error}',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No projects found.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final projects = snapshot.data!;
        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return ProjectIdeaCardWidget(
              refreshIdeasInProfile: () => context.read().add(LoadProfile(widget.userId)),
              idea: project,
              announcementRepository: _announcementRepository,
              repository: _projectIdeaRepository,
            );
          },
        );
      },
    );
  }

  // Limit the text for long names
  String _limitText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + '...';
  }
}
