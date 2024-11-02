// home_screen.dart

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_page_bloc.dart';
import '../bloc/home_page_event.dart';
import '../bloc/home_page_state.dart';
import '../widgets/best_collaborators_widget.dart';
import '../widgets/projects_widget.dart';
import '../src/home_page_repository.dart';
import '../../../authentication/bloc/authentication_bloc.dart';
import '../../../authentication/bloc/authentication_event.dart';
import '../../../authentication/bloc/authentication_state.dart';

class HomeScreen extends StatelessWidget {
  
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Logout Confirmation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Are you sure you want to log out from Blade?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _onLogoutButtonPressed(context);
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

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (Route<dynamic> route) => false,
            );
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onLogoutButtonPressed(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    context.read<AuthenticationBloc>().add(LoggedOut());
  }

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  @override
Widget build(BuildContext context) {
  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return WillPopScope(
    onWillPop: () async => false, // Disable the back navigation action
    child: BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar( // Remove const here
              content: Text(
                'Logged out successfully!',
                style: TextStyle(color: isDarkMode ? Colors.white : TColors.textPrimary),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              showCloseIcon: true,
            ),
          );
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/welcome',
              (Route<dynamic> route) => false,
            );
          }
        },
        child: Scaffold(
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
                        _buildHeader(context, state.currentUser),
                        const SizedBox(height: 30),
                        _buildIntro(context),
                        const SizedBox(height: 30),
                        _buildSearchBar(context),
                        const SizedBox(height: 20),
                        // if (_searchController.text.isEmpty)
                        //   BestCollaboratorsWidget(collaborators: state.collaborators),
                        const SizedBox(height: 20),
                        ProjectsWidget(projects: state.projects),
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
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
        children: [
          Icon(Icons.search, color: Color(0xFF8D8DA6)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search by project name',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Color(0xFF8D8DA6),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  context.read<HomeBloc>().add(SearchProjectEvent(query));
                } else {
                  context.read<HomeBloc>().add(ClearSearchEvent());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Collaborator? currentUser) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 345,
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: currentUser != null
                    ? Container(
                        margin: const EdgeInsets.all(2),
                        width: 66,
                        height: 66,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                            image: NetworkImage(currentUser.profilePhotoUrl),
                            fit: BoxFit.cover,
                          ),
                          shape: OvalBorder(),
                        ),
                      )
                    : Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Color(0xFF7C7C7C) ,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    currentUser != null 
                        ? '${currentUser.firstName} ${currentUser.lastName}' 
                        : 'Guest',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : TColors.textPrimary,
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
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(Icons.logout, size: 24, color: isDarkMode ? Colors.white70 : Colors.grey[600]),
              onPressed: () => _showLogoutConfirmation(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntro(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore!',
          style: TextStyle(
            color: isDarkMode ? Colors.white : TColors.black,
            fontSize: 36,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Find the best project for you to invest',
          style: TextStyle(
            color: Color(0xFF8D8DA6),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
