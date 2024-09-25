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
import 'features/profile/bloc/screens/collaborator_profile_screen.dart'; // Import the correct profile screens
import 'features/profile/bloc/screens/supporter_profile_screen.dart'; // Import the correct profile screens

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Updated method to include confirmation message
  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());

    // Show a green confirmation message at the top of the page after logout
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Logged out successfully!',
          style: TextStyle(color: Colors.white), // White text color
        ),
        backgroundColor: Colors.green, // Green background color
        behavior: SnackBarBehavior.floating, // Make it floating
        margin: const EdgeInsets.only(
            top: 10, left: 10, right: 10), // Show at the top
      ),
    );
  }

  // Adjusted _onProfileButtonPressed to route to the correct profile screen based on user type
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
          // Decide which profile screen to load based on the user type
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
          // Navigate to the welcome screen and remove all previous routes
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/', // Replace with your WelcomeScreen route
            (Route<dynamic> route) => false,
          );
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
                  automaticallyImplyLeading: false,
                  title: const Text('Collaborator Home'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () =>
                          _showDialog(context), // Use dialog on logout
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
                      // ElevatedButton(
                      //   onPressed: () => _onProfileButtonPressed(
                      // context,
                      //  user.uid,
                      //  true, // Pass 'true' to indicate the user is a collaborator
                      // ),
                      // child: const Text('Go to Profile'),
                      //),
                    ],
                  ),
                ),
              );
            } else if (user is SupporterModel) {
              // Render the home screen for supporters
              return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Supporter Home'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () =>
                          _showDialog(context), // Use dialog on logout
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
                          false, // Pass 'false' to indicate the user is a supporter
                        ),
                        child: const Text('Go to Profile'),
                      ),
                    ],
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
                      onPressed: () =>
                          _showDialog(context), // Use dialog on logout
                    ),
                  ],
                ),
                body: const Center(
                  child: Text('Unknown user type'),
                ),
              );
            }
          } else {
            // If not authenticated, show loading indicator
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

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            style: TextStyle(
                fontWeight: FontWeight.bold), // Bold title for emphasis
          ),
          content: const Text(
            "Are you sure you want to log out from Blade?",
            style:
                TextStyle(color: Colors.black), // Ensure content text is black
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 2),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _onLogoutPressed(context); // Renamed method for logout
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Background color for the button
                foregroundColor: Colors.white, // Text color for the button
                padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10), // Padding for better touch targets
              ),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _onLogoutPressed(BuildContext context) {
    // Dispatch the logout event to the AuthenticationBloc
    context.read<AuthenticationBloc>().add(LoggedOut());

    // After logging out, navigate to the Welcome screen and clear the navigation stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // Assuming '/' is the route for the welcome screen
      (Route<dynamic> route) => false, // Removes all previous routes
    );
  }
}
