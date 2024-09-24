// lib/features/collaborator/presentation/screens/collaborator_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../authentication/bloc/authentication_bloc.dart';
import '../../authentication/bloc/authentication_event.dart';
import '../../authentication/src/collaborator_model.dart';

class CollaboratorHomeScreen extends StatelessWidget {
  final CollaboratorModel user;

  const CollaboratorHomeScreen({super.key, required this.user});

  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Collaborator Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _onLogoutButtonPressed(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome Collaborator ${user.firstName} ${user.lastName}!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
