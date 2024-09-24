// Path: lib/features/profile/screens/supporter_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/supporter_profile_model.dart';
import 'edit_supporter_profile_screen.dart';

class SupporterProfileScreen extends StatelessWidget {
  final String userId;

  const SupporterProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(userId)),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Supporter Profile'),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Check if the current state is ProfileLoaded and if the profile is a SupporterProfileModel
                final state = BlocProvider.of<ProfileViewBloc>(context).state;
                if (state is ProfileLoaded &&
                    state.profile is SupporterProfileModel) {
                  final profile = state.profile as SupporterProfileModel;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSupporterProfileScreen(
                        profile: profile,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ProfileViewBloc, ProfileViewState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded &&
                  state.profile is SupporterProfileModel) {
                final profile = state.profile as SupporterProfileModel;
                return buildSupporterProfile(profile);
              } else if (state is ProfileError) {
                return Center(
                    child: Text('Error: ${state.message}',
                        style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text('Unable to load profile.'));
            },
          ),
        ),
      ),
    );
  }

  Widget buildSupporterProfile(SupporterProfileModel profile) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
                profile.profilePhotoUrl ?? 'https://placeholder.com'),
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.firstName} ${profile.lastName}',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                    color: Colors.blue),
              ),
              const SizedBox(height: 8),
              Text(profile.bio ?? 'No bio available',
                  style: const TextStyle(fontSize: 14, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
