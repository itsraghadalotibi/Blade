// Path: features/profile/screens/edit_supporter_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_supporter_profile_bloc.dart';
import '../bloc/edit_supporter_profile_event.dart';
import '../src/supporter_profile_model.dart';

class EditSupporterProfileScreen extends StatelessWidget {
  final SupporterProfileModel profile;

  const EditSupporterProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Supporter Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocProvider(
          create: (context) => EditSupporterProfileBloc(profileRepository: context.read<ProfileRepository>()),
          child: EditSupporterProfileForm(profile: profile),
        ),
      ),
    );
  }
}

class EditSupporterProfileForm extends StatefulWidget {
  final SupporterProfileModel profile;

  const EditSupporterProfileForm({Key? key, required this.profile}) : super(key: key);

  @override