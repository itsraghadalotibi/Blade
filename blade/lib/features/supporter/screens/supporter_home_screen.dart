// lib/features/supporter/presentation/screens/supporter_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentication/bloc/authentication_bloc.dart';
import '../../authentication/bloc/authentication_event.dart';
import '../../authentication/bloc/authentication_state.dart';
import '../../authentication/src/supporter_model.dart';

class SupporterHomeScreen extends StatelessWidget {
  const SupporterHomeScreen({super.key});

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
            '/welcome',
            (Route<dynamic> route) => false, // Clear all previous routes
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Supporter Home'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
        body: Center(
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is AuthenticationAuthenticated &&
                  state.user is SupporterModel) {
                final user = state.user as SupporterModel;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Supporter ${user.firstName} ${user.lastName}!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
