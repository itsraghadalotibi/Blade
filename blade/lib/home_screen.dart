// lib/home_screen.dart
import 'package:blade_app/features/profile/bloc/bloc/profile_view_bloc.dart';
import 'package:blade_app/features/profile/bloc/bloc/profile_view_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/bloc/authentication_state.dart';
import 'features/authentication/src/collaborator_model.dart';
import 'features/authentication/src/supporter_model.dart';
import 'features/profile/bloc/repository/profile_repository.dart';
import 'features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'features/profile/bloc/screens/supporter_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Method for showing logout confirmation dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
      title: const Text(
        "Logout Confirmation",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        "Are you sure you want to log out from Blade?",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          child: const Text("Cancel"),
        ),
        const SizedBox(width: 2),
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Close the dialog
            _onLogoutButtonPressed(context); // Perform logout
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error, // Red background
          ),
          child: Text(
            "Logout",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError, // White text
            ),
          ),
        ),
      ],
    );
      },
    );
  }

  // Updated method to include confirmation message after logging out
  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());
  }

  // Adjusted _onProfileButtonPressed to route to the correct profile screen
  void _onProfileButtonPressed(
      BuildContext context, String userId, bool isCollaborator) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            RepositoryProvider.value(
              value: context.read<ProfileRepository>(),
            ),
            BlocProvider(
              create: (context) => ProfileViewBloc(
                profileRepository: context.read<ProfileRepository>(),
              )..add(LoadProfile(userId)),
            ),
          ],
          child: isCollaborator
              ? CollaboratorProfileScreen(userId: userId)
              : SupporterProfileScreen(userId: userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          // Show the success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Logged out successfully!',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              showCloseIcon: true,
            ),
          );

          // Navigate to the welcome screen and clear the navigation stack
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (Route<dynamic> route) => false, // Clear all previous routes
          );
        }
      },
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationAuthenticated) {
            final user = state.user;

            if (user is CollaboratorModel) {
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Collaborator Home'),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _showLogoutConfirmation(context),
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Collaborator ${user.firstName} ${user.lastName}!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            } else if (user is SupporterModel) {
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Supporter Home'),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _showLogoutConfirmation(context),
                    ),
                  ],
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Supporter ${user.firstName} ${user.lastName}!',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _onProfileButtonPressed(
                          context,
                          user.uid,
                          false,
                        ),
                        child: const Text('Go to Profile'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Home'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _showLogoutConfirmation(context),
                    ),
                  ],
                ),
                body: const Center(
                  child: Text('Unknown user type'),
                ),
              );
            }
          } else {
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
