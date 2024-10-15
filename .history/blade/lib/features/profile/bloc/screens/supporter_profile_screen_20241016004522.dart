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

class _SupporterProfileScreenState extends State<SupporterProfileScreen> {
  String? _currentUserId;
  SupporterProfileModel? _updatedProfile;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 75,
            backgroundImage: profile.profilePhotoUrl != null
                ? NetworkImage(profile.profilePhotoUrl!)
                : const AssetImage('assets/images/user.png') as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text('${profile.firstName} ${profile.lastName}',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          Text(profile.bio ?? 'No bio available'),
          // You can add other fields here like the investment tab bar or ongoing projects
        ],
      ),
    );
  }
}
