import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:blade_app/features/authentication/bloc/authentication_bloc.dart';
import 'package:blade_app/features/authentication/bloc/authentication_state.dart';
import 'package:blade_app/features/authentication/src/collaborator_model.dart';
import 'package:blade_app/features/collaborator/screens/collaborator_home_screen.dart';
import 'package:blade_app/features/newPost/screens/github_oauth.dart';
import 'package:blade_app/features/notification/screen/NotificationScreen.dart';
import 'package:blade_app/features/profile/bloc/bloc/profile_view_bloc.dart';
import 'package:blade_app/features/profile/bloc/bloc/profile_view_event.dart';
import 'package:blade_app/features/profile/bloc/repository/profile_repository.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'package:blade_app/features/profile/bloc/screens/supporter_profile_screen.dart';
import 'package:blade_app/features/project_info/screens/new_post.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart' as settings;
import 'package:blade_app/utils/constants/Navigation/settings.dart';
import 'package:flutter/material.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart'; // Import the repository
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../features/announcement/screens/announcement_screen.dart';

import '../../../features/newPost/screens/backgroundPost.dart';
import '../colors.dart';
import 'profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final AnnouncementRepository announcementRepository =
      AnnouncementRepository();
  final ProjectIdeaRepository projectIdeaRepository = ProjectIdeaRepository();

  int currentTap = 0;
  final List<Widget> screen = [
    const CollaboratorHomeScreen(),
    const Profile(),
    const Settings(),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const CollaboratorHomeScreen();

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      String currentUserId = '';
      if (state is AuthenticationAuthenticated) {
        currentUserId =
            state.user.uid; // Ensure the user model has a uid property
      }

      return Scaffold(
        body: PageStorage(bucket: bucket, child: currentScreen),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
              ),
              backgroundColor: const Color(0xFF333333),
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return Wrap(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const GithubAuthentication()),
                        );
                      },
                      child: const ListTile(
                        leading: Icon(Icons.announcement, color: Colors.white),
                        title: Text(
                          'New Idea',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    InkWell(
                      onTap: () async {
                        List<Idea>? ideas = await projectIdeaRepository
                            .fetchIdeasForDropdownButton(currentUserId);
                        Navigator.pop(context);
                        if (ideas.isEmpty) {
                          showSnakbar(
                              icon: Icons.error,
                              color: TColors.error,
                              title: 'There are no projects.');
                        }
                        var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewPost(
                                    ideas: ideas,
                                  )),
                        );
                        if (res != null && res == "DONE") {
                          showSnakbar(
                              icon: Icons.error,
                              color: TColors.success,
                              title: 'Post sent Succesfully.');
                        }
                      },
                      child: const ListTile(
                        leading: Icon(Icons.add, color: Colors.white),
                        title: Text(
                          'New Post',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Container(
                    //   padding: const EdgeInsets.all(30),
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //       bottom: MediaQuery.of(context).viewInsets.bottom,
                    //     ),
                    //   ),
                    // ),
                  ],
                );
              },
            );
          },
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFFD5336),
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: isDarkMode ? TColors.black : TColors.white,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          height: 50,
          child: SingleChildScrollView(
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Left side navigation
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 30,
                        onPressed: () {
                          setState(() {
                            currentScreen = const CollaboratorHomeScreen();
                            currentTap = 0;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: currentTap == 0
                                  ? const Color(0xFFFD5336)
                                  : Colors.grey,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          width: 15), // Adjust the width for desired spacing

                      MaterialButton(
                        minWidth: 30,
                        onPressed: () {
                          if (currentUserId.isNotEmpty) {
                            setState(() {
                              currentScreen = AnnouncementScreen(
                                repository: announcementRepository,
                                currentUserId:
                                    currentUserId, // Pass the current user ID
                              );
                              currentTap = 1;
                            });
                          } else {
                            // If currentUserId is empty, show a snackbar or redirect to login
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("User not authenticated")),
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/content/announcement.png',
                              color: currentTap == 1
                                  ? const Color(0xFFFD5336)
                                  : Colors.grey, // Tint color
                              width:
                                  30, // Set the width to 25 to match your original icon size
                              height:
                                  30, // Set the height to 25 to match your original icon size
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          width: 15), // Adjust the width for desired spacing
                    ],
                  ),

                  // Right side navigation
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 30,
                        onPressed: () {
                          setState(() {
                            currentScreen = const NotificationScreen(
                              userId: '',
                            );
                            currentTap = 2;
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications,
                              color: currentTap == 2
                                  ? const Color(0xFFFD5336)
                                  : Colors.grey,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          width: 15), // Adjust the width for desired spacing

                      MaterialButton(
                        minWidth: 30,
                        onPressed: () {
                          // Check if the current state is AuthenticationAuthenticated
                          if (state is AuthenticationAuthenticated) {
                            final user = state.user;
                            final bool isCollaborator =
                                user is CollaboratorModel;

                            setState(() {
                              currentScreen = MultiProvider(
                                providers: [
                                  RepositoryProvider.value(
                                    value: context.read<ProfileRepository>(),
                                  ),
                                  BlocProvider(
                                    create: (context) => ProfileViewBloc(
                                      profileRepository:
                                          context.read<ProfileRepository>(),
                                    )..add(LoadProfile(user.uid)),
                                  ),
                                ],
                                child: isCollaborator
                                    ? CollaboratorProfileScreen(
                                        userId: user.uid)
                                    : SupporterProfileScreen(userId: user.uid),
                              );
                              currentTap = 3;
                            });
                          } else {
                            // If the user is not authenticated, show a snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("User not authenticated")),
                            );
                          }
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: currentTap == 3
                                  ? const Color(0xFFFD5336)
                                  : Colors.grey,
                              size: 30,
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  showSnakbar(
      {required IconData icon, required Color color, required String title}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color, // Success background color
        behavior: SnackBarBehavior.floating,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon, // Success icon
              color: Colors.white,
            ),
            const SizedBox(width: 8), // Space between icon and text
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
