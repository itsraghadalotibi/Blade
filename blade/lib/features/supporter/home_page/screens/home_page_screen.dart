import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/bloc/authentication_bloc.dart';
import '../../../authentication/bloc/authentication_event.dart';
import '../../../authentication/bloc/authentication_state.dart';
import 'home_page_bloc.dart';
import 'home_page_event.dart';
import 'home_page_state.dart';
import 'best_collaborators_widget.dart';
import 'completed_projects_widget.dart';
import 'home_page_repository.dart';

class HomeScreen extends StatelessWidget {
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

  void _onLogoutButtonPressed(BuildContext context) {
    context.read<AuthenticationBloc>().add(LoggedOut());
    Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (Route<dynamic> route) => false, // Clear all previous routes
          );
  }
  @override
  Widget build(BuildContext context) {
    (context, state) {
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
      };
    return Scaffold(
      body: BlocProvider(
        create: (context) => HomeBloc(
          userRepository: UserRepository(),
          projectRepository: ProjectRepository(),
        )..add(LoadHomeData()),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is HomeLoaded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _showLogoutConfirmation(context),
            ),
                    _buildHeader(state.currentUser),
                    const SizedBox(height: 30),
                    _buildIntro(),
                    const SizedBox(height: 30),
                    _buildSearchBar(context),
                    const SizedBox(height: 20),
                    BestCollaboratorsWidget(collaborators: state.collaborators),
                    const SizedBox(height: 20),
                    CompletedProjectsWidget(projects: state.completedProjects), // Completed projects widget
                  ],
                ),
              );
            } else if (state is HomeError) {
              return Center(child: Text(state.message));
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Collaborator currentUser) {
    return Container(
      width: 345,
      height: 70,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: profile picture and user information
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Container(
                width: 70,
                height: 70,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        width: 70,
                        height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4fe3c2), // First color
                            Color(0xFF6febf4), // Second color
                          ],
                          begin: Alignment.center, // Starting point of the gradient
                          end: Alignment.bottomRight, // Ending point of the gradient
                        ),
                        borderRadius: BorderRadius.circular(48), // Rounded corners
                      ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      top: 2,
                      child: Container(
                        width: 66,
                        height: 66,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(currentUser.profilePhotoUrl),
                            fit: BoxFit.cover,
                          ),
                          shape: OvalBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Welcome text and user name
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      color: Color(0xFF7C7C7C),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '${currentUser.firstName} ${currentUser.lastName}',
                    style: TextStyle(
                      color: Color(0xFF050527),
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Right side: Notification icon (with badge)
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 55,
                  height: 55,
                  child: Stack(
                    children: [
                      // Notification circle
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      // Notification bell icon placeholder (replace with actual icon as needed)
                      Positioned(
                        left: 16,
                        top: 15.5,
                        child: Container(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.notifications,
                            size: 24,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      // Notification badge
                      Positioned(
                        left: 30,
                        top: 18.5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFF2929),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchBar(BuildContext context) {
    return Container(
      width: 345,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start, // Use start to align items
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          // Search Icon
          Container(
            width: 24,
            height: 24,
            child: Icon(Icons.search, color: Color(0xFF8D8DA6)), // Added search icon
          ),
          const SizedBox(width: 16),
          // TextField for search input
          Expanded(
            child: Container(
              child: TextField(
                style: TextStyle(fontSize: 16), // Ensure text style matches
                decoration: InputDecoration(
                  hintText: 'Search by project name',
                  hintStyle: TextStyle(
                    color: Color(0xFF8D8DA6), // Match the hint text color
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none, // No border when idle
                  enabledBorder: InputBorder.none, // No border when enabled
                  focusedBorder: InputBorder.none, // No border when focused
                ),
                onChanged: (query) {
                  // Trigger the search event on text change
                  context.read<HomeBloc>().add(SearchProjectEvent(query));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



 Widget _buildIntro() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,  // Aligns children to the left
    children: [
      Text(
        'Explore!',
        style: TextStyle(
          color: Color(0xFF050527),
          fontSize: 36,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          height: 0,
        ),
      ),
      SizedBox(height: 6),
      Text(
        'Find the best project for you to invest',
        style: TextStyle(
          color: Color(0xFF8D8DA6),
          fontSize: 16,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
          height: 0,
        ),
      ),
    ],
  );
}
}
