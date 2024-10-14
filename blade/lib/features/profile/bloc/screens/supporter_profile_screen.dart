import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_view_bloc.dart';
import '../bloc/profile_view_event.dart';
import '../bloc/profile_view_state.dart';
import '../src/supporter_profile_model.dart';

class SupporterProfileScreen extends StatefulWidget {
  final String userId;

  const SupporterProfileScreen({super.key, required this.userId});

  @override
  _SupporterProfileScreenState createState() => _SupporterProfileScreenState();
}

class _SupporterProfileScreenState extends State<SupporterProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileViewBloc(profileRepository: context.read())
        ..add(LoadProfile(widget.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supporter Profile'),
          centerTitle: true,
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
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Unable to load profile.'));
          },
        ),
      ),
    );
  }

  Widget buildSupporterProfile(SupporterProfileModel profile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: profile.profilePhotoUrl != null
                  ? NetworkImage(profile.profilePhotoUrl!)
                  : const AssetImage('assets/images/user.png') as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              '${profile.firstName} ${profile.lastName}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              profile.bio ?? 'No bio available',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}