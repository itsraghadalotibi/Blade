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
  int currentTap = 3; // Profile Tab selected by default
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const Profile();
  late TabController _tabController; // TabController for managing tab view
  final announcementRepository = AnnouncementRepository(
    firestore:
        FirebaseFirestore.instance, // Use correct repository for announcements
  );

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
              color: Colors.orange, // Ensure consistent orange color
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true, // Center the title "Profile"
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
        body: SingleChildScrollView(
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              backgroundColor: const Color(0xFF333333),
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return Wrap(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => backgroundScreen()),
                        );
                      },
                      child: const ListTile(
                        leading: Icon(Icons.announcement, color: Colors.white),
                        title: Text(
                          'New Idea',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    InkWell(
                      onTap: () {
                        // Add functionality for new post here
                      },
                      child: const ListTile(
                        leading: Icon(Icons.post_add, color: Colors.white),
                        title: Text(
                          'New Post',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(30),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFFD5336),
          child: const Icon(Icons.add, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = const HomeScreen();
                        currentTap = 0;
                      });
                    },
                    child: Icon(
                      Icons.home,
                      color: currentTap == 0
                          ? const Color(0xFFFD5336)
                          : Colors.grey,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = AnnouncementScreen(
                            repository:
                                announcementRepository); // Use correct repository here
                        currentTap = 1;
                      });
                    },
                    child: Image.asset(
                      'assets/images/content/announcement.png',
                      color: currentTap == 1
                          ? const Color(0xFFFD5336)
                          : Colors.grey,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = const settings.Settings();
                        currentTap = 2;
                      });
                    },
                    child: Icon(
                      Icons.notifications,
                      color: currentTap == 2
                          ? const Color(0xFFFD5336)
                          : Colors.grey,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 15),
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = const Profile();
                        currentTap = 3;
                      });
                    },
                    child: Icon(
                      Icons.person,
                      color: currentTap == 3
                          ? const Color(0xFFFD5336)
                          : Colors.grey,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCollaboratorProfile(CollaboratorProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile picture back to its original place
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 50,
          backgroundImage: profile.profilePhotoUrl != null
              ? NetworkImage(profile.profilePhotoUrl!)
              : const AssetImage('assets/images/user.png') as ImageProvider,
        ),
        const SizedBox(height: 16),
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
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.github,
                color: profile.socialMediaLinks?['GitHub'] != null
                    ? TColors.primary
                    : Colors.grey,
                size: 24,
              ),
              onPressed: profile.socialMediaLinks?['GitHub'] != null
                  ? () {
                      launch(profile.socialMediaLinks!['GitHub']!);
                    }
                  : null,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.linkedin,
                color: profile.socialMediaLinks?['LinkedIn'] != null
                    ? TColors.primary
                    : Colors.grey,
                size: 24,
              ),
              onPressed: profile.socialMediaLinks?['LinkedIn'] != null
                  ? () {
                      launch(profile.socialMediaLinks!['LinkedIn']!);
                    }
                  : null,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                );
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
                  color: Colors.orange),
            ),
            const SizedBox(height: 8),
            Text(profile.bio ?? 'No bio available',
                style: const TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 16),
        buildTabBarSection(),
      ],
    );
  }

  Widget buildTabBarSection() {
    return DefaultTabController(
      length: 3, // Three tabs: Project Ideas, Ongoing, and Completed
      child: Column(
        children: [
          const TabBar(
            indicatorColor: TColors.primary,
            labelColor: TColors.primary,
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
