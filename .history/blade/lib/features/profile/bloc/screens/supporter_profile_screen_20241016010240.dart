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
  SupporterProfileModel? _updatedProfile;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _tabController = TabController(
        length: 2, vsync: this); // 2 tabs for investments and completed
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
                    onPressed: () async {
                      final state = context.read<ProfileViewBloc>().state;
                      if (state is ProfileLoaded &&
                          state.profile is SupporterProfileModel) {
                        final supporterProfile =
                            state.profile as SupporterProfileModel;

                        // Navigate to the edit screen and await the result
                        final updatedProfile = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => EditSupporterProfileBloc(
                                profileRepository:
                                    context.read<ProfileRepository>(),
                              ),
                              child: EditSupporterProfileScreen(
                                profile: supporterProfile,
                              ),
                            ),
                          ),
                        );

                        // If an updated profile is returned, refresh the profile screen
                        if (updatedProfile != null &&
                            updatedProfile is SupporterProfileModel) {
                          setState(() {
                            _updatedProfile = updatedProfile;
                          });
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
                        state.profile is SupporterProfileModel
                    ? state.profile as SupporterProfileModel
                    : null);

            if (profile != null) {
              return _buildProfile(profile);
            } else if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Unable to load profile.'));
          },
        ),
      ),
    );
  }

  Widget _buildProfile(SupporterProfileModel profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16), // Space above the avatar
          CircleAvatar(
            radius: 70,
            backgroundImage: profile.profilePhotoUrl != null
                ? NetworkImage(profile.profilePhotoUrl!)
                : const AssetImage('assets/images/user.png') as ImageProvider,
          ),
          const SizedBox(height: 16), // Spacing between image and name
          Text(
            _limitText('${profile.firstName} ${profile.lastName}',
                20), // Limiting to 20 characters
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis, // Ellipsis for overflow
          ),
          const SizedBox(height: 8), // Spacing between name and "About"
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700, // Dynamic color based on theme
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // Spacing between "About" and bio
          Text(
            profile.bio ?? 'No bio available',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24), // Add space before the TabBar
          _buildTabBarSection(), // Add TabBar for Investments and Completed
        ],
      ),
    );
  }

  // Function to limit the length of the text and add ellipsis
  String _limitText(String text, int maxLength) {
    if (text.length > maxLength) {
      return text.substring(0, maxLength) + '...';
    }
    return text;
  }

  Widget _buildTabBarSection() {
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
        SizedBox(
          height: 200, // Fixed height for the TabBar content
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInvestmentsTab(),
              _buildCompletedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentsTab() {
    // You can replace this with actual investment data later
    return Center(
      child: Text(
        'No investments yet.',
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildCompletedTab() {
    // You can replace this with actual completed projects data later
    return Center(
      child: Text(
        'No completed projects yet.',
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
