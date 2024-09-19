// lib/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/bloc/authentication_state.dart';
import 'features/authentication/src/collaborator_model.dart';
import 'features/authentication/src/supporter_model.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          // Navigate to WelcomeScreen when unauthenticated
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            final user = state.user;

            if (user is CollaboratorModel) {
              // Render the home screen for collaborators
              return Scaffold(
                appBar: AppBar(
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
            } else if (user is SupporterModel) {
              // Render the home screen for supporters
              return Scaffold(
                appBar: AppBar(
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
            } else {
              // Handle unexpected user type
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Home'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _onLogoutButtonPressed(context),
                    ),
                  ],
                ),
                body: const Center(
                  child: Text('Unknown user type'),
                ),
              );
            }
          } else {
            // If not authenticated, redirect to WelcomeScreen
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
