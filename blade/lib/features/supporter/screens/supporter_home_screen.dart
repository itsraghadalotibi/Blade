// lib/features/supporter/presentation/screens/supporter_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentication/bloc/authentication_bloc.dart';
import '../../authentication/bloc/authentication_event.dart';
import '../../authentication/src/supporter_model.dart';


class SupporterHomeScreen extends StatelessWidget {
  final SupporterModel user;

  const SupporterHomeScreen({Key? key, required this.user}) : super(key: key);

  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Supporter Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _onLogoutButtonPressed(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome Supporter ${user.firstName} ${user.lastName}!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
