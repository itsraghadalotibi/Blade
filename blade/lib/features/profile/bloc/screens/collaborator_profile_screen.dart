import 'dart:async';
import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart';
import 'package:blade_app/features/announcement/widgets/skill_tag_widget.dart';
import 'package:blade_app/features/authentication/bloc/authentication_bloc.dart';
import 'package:blade_app/features/authentication/bloc/authentication_event.dart';
import 'package:blade_app/features/authentication/bloc/authentication_state.dart';
import 'package:blade_app/features/profile/bloc/screens/edit_collaborator_profile_screen.dart';
import 'package:blade_app/utils/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Add this import
import '../../../investment_request/bloc/investment_request_bloc.dart';
import '../../../investment_request/screens/invsetment_request_list.dart';
import '../../../investment_request/src/investment_request_repository.dart';
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
  int totalPendingRequestsCount = 0;
  StreamSubscription<QuerySnapshot>? _pendingRequestsSubscription;


  List<StreamSubscription<QuerySnapshot>> _pendingRequestsSubscriptions = [];
  List<String> _ownerProjectIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _projectIdeaRepository = ProjectIdeaRepository();
    _announcementRepository = AnnouncementRepository();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId != null) {
      _subscribeToPendingRequests();
    }
  }

  Future<List<String>> _fetchOwnedProjectIds() async {
    final projectsSnapshot = await FirebaseFirestore.instance
        .collection('ideas')
        .where('members', arrayContains: _currentUserId)
        .get();

    List<String> ownerProjectIds = [];

    for (var doc in projectsSnapshot.docs) {
      List<dynamic> members = doc['members'];
      if (members.isNotEmpty && members[0] == _currentUserId) {
        ownerProjectIds.add(doc.id);
      }
    }

    return ownerProjectIds;
  }

  void _subscribeToPendingRequests() async {
    _ownerProjectIds = await _fetchOwnedProjectIds();

    // Cancel any existing subscriptions
    for (var subscription in _pendingRequestsSubscriptions) {
      subscription.cancel();
    }
    _pendingRequestsSubscriptions.clear();

    // Set up new subscriptions
    for (String projectId in _ownerProjectIds) {
      final subscription = FirebaseFirestore.instance
          .collection('investment_requests')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'Pending')
          .snapshots()
          .listen((snapshot) {
        _recalculateTotalPendingRequests();
      });

      _pendingRequestsSubscriptions.add(subscription);
    }

    // Initial calculation
    _recalculateTotalPendingRequests();
  }

  void _recalculateTotalPendingRequests() async {
    int count = 0;

    for (String projectId in _ownerProjectIds) {
      final snapshot = await FirebaseFirestore.instance
          .collection('investment_requests')
          .where('projectId', isEqualTo: projectId)
          .where('status', isEqualTo: 'Pending')
          .get();

      count += snapshot.docs.length;
    }

    setState(() {
      totalPendingRequestsCount = count;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var subscription in _pendingRequestsSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _navigateToInvestmentRequests() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => InvestmentRequestBloc(
          repository: context.read<InvestmentRequestRepository>(),
        ),
        child: InvestmentRequestsListScreen(
          userId: widget.userId,
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final bool isOwner = _currentUserId == widget.userId;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Logged out successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              showCloseIcon: true,
            ),
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (Route<dynamic> route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            leading: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {},
            ),
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
          centerTitle: true,
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.logout,
          //     color:
          //         Theme.of(context).iconTheme.color, // Match theme icon color
          //   ),
          //   onPressed: () {
          //     _showLogoutConfirmation(context);
          //   },
          // ),
          actions: [
                  IconButton(
                icon: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/investment_request.svg',
                      color: Theme.of(context).iconTheme.color,
                      width: 30,
                      height: 30,
                    ),
                    if (totalPendingRequestsCount > 0)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '$totalPendingRequestsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: _navigateToInvestmentRequests,
              ),
                
    if (isOwner)
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
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: profile.profilePhotoUrl != null &&
                            profile.profilePhotoUrl!.isNotEmpty
                        ? NetworkImage(profile.profilePhotoUrl!)
                        : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 8),
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
                      const SizedBox(width: 3),
                      Row(
                        children: [
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.github,
                              color: profile.socialMediaLinks?['GitHub']
                                          ?.isNotEmpty ==
                                      true
                                  ? TColors.primary
                                  : Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
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
                          const SizedBox(width: 0),
                          IconButton(
                            icon: FaIcon(
                              FontAwesomeIcons.linkedin,
                              color: profile.socialMediaLinks?['LinkedIn']
                                          ?.isNotEmpty ==
                                      true
                                  ? TColors.primary
                                  : Colors.grey,
                            ),
                            padding: EdgeInsets.zero,
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
                  if (profile.skills != null && profile.skills!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        height: 50,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: profile.skills!.map((skill) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: SkillTagWidget(skills: [skill]),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    profile.bio ?? 'No bio available',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    maxLines:
                                        isBioExpanded ? null : maxBioLines,
                                    overflow: isBioExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                if (exceedsMaxLines)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isBioExpanded = !isBioExpanded;
                                      });
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        isBioExpanded
                                            ? 'Show less'
                                            : 'Show more',
                                        style: const TextStyle(
                                            color: TColors.info),
                                      ),
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
              buildProjectTab(
                  "open",
                  LinearGradient(
                    colors: [
                      Color.fromARGB(255, 120, 215, 219),
                      Color.fromARGB(255, 12, 107, 89)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
              buildProjectTab(
                  "ongoing",
                  LinearGradient(
                    colors: [
                      Color.fromARGB(255, 14, 97, 176),
                      Color.fromARGB(255, 69, 142, 187)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
              buildProjectTab(
                  "completed",
                  LinearGradient(
                    colors: [
                      Color(0xFFFD5336),
                      Color.fromARGB(255, 237, 122, 70)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProjectTab(String status, Gradient cardGradient) {
    return FutureBuilder<List<Idea>>(
      future: _projectIdeaRepository.fetchIdeasByOwner(widget.userId, status),
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
              idea: project,
              announcementRepository: _announcementRepository,
              repository: _projectIdeaRepository,
              refreshIdeasInProfile: () {
                context.read<ProfileViewBloc>().add(LoadProfile(widget.userId));
              },
              cardGradient: cardGradient,
            );
          },
        );
      },
    );
  }

  // Method for showing logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out from Blade?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 2),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _onLogoutButtonPressed(context); // Perform logout
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.error, // Red background
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError, // White text
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Logout button action
  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());

    // Ensure proper navigation after logout
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/', // Route name for your login or welcome screen
        (route) => false, // Remove all previous routes
      );
    });
  }

  String _limitText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return text.substring(0, maxLength) + '...';
  }
}
