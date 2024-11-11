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
import '../../../announcement/src/announcement_repository.dart'; // Import AnnouncementRepository
import '../../../authentication/bloc/authentication_bloc.dart';
import '../../../authentication/bloc/authentication_event.dart';
import '../../../authentication/bloc/authentication_state.dart';
import '../../../announcement/screens/members_screen.dart';
import '../widgets/result_collaborators_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'Projects';

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationUnauthenticated) {
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
                        const SizedBox(height: 10),
                        if (_searchQuery.isNotEmpty) _buildTabs(), // Show tabs only if there is text in the search bar
                        const SizedBox(height: 10),
                        _buildSearchResults(state),
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
        color: isDarkMode ? TColors.container : TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDarkMode ? Colors.white70 : Color(0xFF8D8DA6)),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              controller: _searchController,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search by project or collaborator name',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Color(0xFF8D8DA6),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  // Keep the selected tab as is when the user types in the search bar
                });
                if (query.isNotEmpty) {
                  context.read<HomeBloc>().add(SearchEvent(query));
                } else {
                  context.read<HomeBloc>().add(ClearSearchEvent());
                }
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Color(0xFF8D8DA6)),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
                context.read<HomeBloc>().add(ClearSearchEvent());
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab('Projects'),
        const SizedBox(width: 16),
        _buildTab('Collaborators'),
      ],
    );
  }

  Widget _buildTab(String title) {
    final bool isSelected = _selectedTab == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = title),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? TColors.primary : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

Widget _buildSearchResults(HomeLoaded state) {
  if (_searchQuery.isEmpty) {
    return Column(
      children: [
        BestCollaboratorsWidget(collaborators: state.collaborators),
        const SizedBox(height: 20),
        ProjectsWidget(projects: state.projects, showDiscoverText: true),
      ],
    );
  }

  // Render `ProjectsWidget` or `ResultCollaboratorsWidget` based on selected tab
  if (_selectedTab == 'Projects') {
    return ProjectsWidget(
      projects: state.filteredProjects,
      showDiscoverText: false, // Hide the discover text if search query is present
    );
  } else if (_selectedTab == 'Collaborators') {
    return ResultCollaboratorsWidget(
      collaborators: state.filteredCollaborators,
    );
  }

  return Container();
}


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
    context.read<AuthenticationBloc>().add(LoggedOut());
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
                      color: isDarkMode ? Colors.white70 : Color(0xFF7C7C7C),
                      fontSize: 14,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Find the best project for you to invest',
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Color(0xFF8D8DA6),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
