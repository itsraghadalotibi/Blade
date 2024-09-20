// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/collaborator_profile_model.dart';

class ProfileScreen extends StatelessWidget {
  final String userId; // Expecting userId to be passed in

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(userId)), // Dispatch LoadProfile with the userId
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<ProfileViewBloc, ProfileViewState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileLoaded) {
                final profile = state.profile
                    as CollaboratorProfileModel; // Assuming it's a collaborator
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture with Edit Icon
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(
                                profile.profilePhotoUrl ??
                                    'https://placeholder.com'),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.edit, size: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Name and Social Media Links
                      Column(
                        children: [
                          Text(
                            '${profile.firstName} ${profile.lastName}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (profile.socialMediaLinks != null) ...[
                                Icon(Icons.link,
                                    color: Colors
                                        .blue), // Replace with actual social icons
                                Icon(Icons.business, color: Colors.blue),
                              ],
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Skill Chips (Already implemented)
                      Wrap(
                        spacing: 8.0,
                        children: profile.skills?.split(',').map((skill) {
                              return Chip(
                                label: Text(skill),
                                backgroundColor: Colors.red,
                              );
                            }).toList() ??
                            [],
                      ),

                      const SizedBox(height: 16),

                      // About Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.bio ?? 'No bio available',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tab Bar for Projects
                      DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: Colors.blue,
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.white,
                              tabs: const [
                                Tab(text: 'Project Ideas'),
                                Tab(text: 'Ongoing '),
                                Tab(text: 'Completed '),
                              ],
                            ),
                            SizedBox(
                              height: 300, // Content height for tabs
                              child: TabBarView(
                                children: [
                                  Text('Project Ideas content here...'),
                                  Text('Ongoing Projects content here...'),
                                  Text('Completed Projects content here...'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
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
}
