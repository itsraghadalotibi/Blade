import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/edit_collaborator_profile_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../screens/edit_collaborator_profile_screen.dart';
import '../repository/profile_repository.dart';

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
  late TabController _tabController;

  // Variables for bio expansion
  bool isBioExpanded = false;
  static const int maxBioLines = 3; // Limit bio to 3 lines initially
  String? _currentUserId; // Variable to hold the authenticated user's ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

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
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          automaticallyImplyLeading: widget.showBackButton,
          actions: isOwner
              ? [
                  BlocBuilder<ProfileViewBloc, ProfileViewState>(
                    builder: (context, state) {
                      bool isProfileLoaded = state is ProfileLoaded &&
                          state.profile is CollaboratorProfileModel;
                      return IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: isProfileLoaded
                            ? () async {
                                final collaboratorProfile =
                                    state.profile as CollaboratorProfileModel;

                                final updatedProfile = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) =>
                                          EditCollaboratorProfileBloc(
                                        profileRepository:
                                            context.read<ProfileRepository>(),
                                      ),
                                      child: EditCollaboratorProfileScreen(
                                        profile: collaboratorProfile,
                                      ),
                                    ),
                                  ),
                                );

                                if (updatedProfile != null &&
                                    updatedProfile
                                        is CollaboratorProfileModel) {
                                  setState(() {
                                    _updatedProfile = updatedProfile;
                                  });

                                  context
                                      .read<ProfileViewBloc>()
                                      .add(LoadProfile(widget.userId));
                                }
                              }
                            : null, // Disable the button until profile is loaded
                      );
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
                            _limitText('${profile.firstName}', 20),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _limitText('${profile.lastName}', 20),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bio Section with Expand/Collapse functionality
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0), // Padding
                    child: LayoutBuilder(
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
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
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
              const Center(child: Text('Ideas content here...')),
              const Center(child: Text('Ongoing Projects content here...')),
              const Center(child: Text('Completed Projects content here...')),
            ],
          ),
        ),
      ],
    );
  }

  // Utility to limit text length for names, etc.
  String _limitText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + '...';
  }
}
