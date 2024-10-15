import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/supporter_profile_model.dart';
import 'edit_supporter_profile_screen.dart';
import '../bloc/edit_supporter_profile_bloc.dart'; // Import EditSupporterProfileBloc
import '../repository/profile_repository.dart'; // Import ProfileRepository

class SupporterProfileScreen extends StatefulWidget {
  final String userId;
  final bool showBackButton;

  const SupporterProfileScreen({
    super.key,
    required this.userId,
    this.showBackButton = false,
  });

  @override
  _SupporterProfileScreenState createState() => _SupporterProfileScreenState();
}

class _SupporterProfileScreenState extends State<SupporterProfileScreen>
    with SingleTickerProviderStateMixin {
  String? _currentUserId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _tabController = TabController(
        length: 2, vsync: this); // Two tabs for Investments and Completed
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
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          automaticallyImplyLeading: widget.showBackButton,
          actions: isOwner
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      final state = context.read<ProfileViewBloc>().state;
                      if (state is ProfileLoaded &&
                          state.profile is SupporterProfileModel) {
                        final supporterProfile =
                            state.profile as SupporterProfileModel;

                        // Wrap EditSupporterProfileScreen in BlocProvider
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => EditSupporterProfileBloc(
                                profileRepository:
                                    context.read<ProfileRepository>(),
                              ),
                              child: EditSupporterProfileScreen(
                                profile:
                                    supporterProfile, // Pass the profile here
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ]
              : null,
        ),
        body: BlocBuilder<ProfileViewBloc, ProfileViewState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded &&
                state.profile is SupporterProfileModel) {
              final profile = state.profile as SupporterProfileModel;
              return buildSupporterProfile(profile);
            } else if (state is ProfileError) {
              return Center(
                  child: Text(
                'Error: ${state.message}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ));
            }
            return const Center(child: Text('Unable to load profile.'));
          },
        ),
      ),
    );
  }

  Widget buildSupporterProfile(SupporterProfileModel profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.profilePhotoUrl != null
                        ? NetworkImage(profile.profilePhotoUrl!)
                        : const AssetImage('assets/images/user.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 16),

                  // First Name and Last Name
                  Text(
                    '${profile.firstName} ${profile.lastName}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // About Section with Bio
                  if (profile.bio != null) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Dynamic color
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ]),
          ),
        ];
      },
      body: buildTabBarSection(),
    );
  }

  // Build TabBar Section for "Investments" and "Completed" tabs
  Widget buildTabBarSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          tabs: const [
            Tab(text: 'Investments'),
            Tab(text: 'Completed'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              buildInvestmentsTab(),
              const Center(
                  child: Text('Completed investments will be shown here...')),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder for Investments Tab
  Widget buildInvestmentsTab() {
    return const Center(
      child: Text(
        'No investments yet.',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
