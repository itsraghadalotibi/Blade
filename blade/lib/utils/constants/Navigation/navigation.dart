import 'package:blade_app/features/authentication/bloc/authentication_bloc.dart';
import 'package:blade_app/features/authentication/bloc/authentication_state.dart';
import 'package:blade_app/features/authentication/src/collaborator_model.dart';
import 'package:blade_app/features/collaborator/screens/collaborator_home_screen.dart';
import 'package:blade_app/features/profile/bloc/bloc/profile_view_bloc.dart';
import 'package:blade_app/features/profile/bloc/bloc/profile_view_event.dart';
import 'package:blade_app/features/profile/bloc/repository/profile_repository.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'package:blade_app/features/profile/bloc/screens/supporter_profile_screen.dart';
import 'package:blade_app/utils/constants/Navigation/dashboard.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart' as settings;
import 'package:flutter/material.dart';
import 'package:blade_app/features/announcement/src/announcement_repository.dart'; // Import the repository
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase import
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
  final announcementRepository = AnnouncementRepository(
    firestore: FirebaseFirestore.instance,
  );

  int currentTap = 0;
  final List<Widget> screen = [
    const CollaboratorHomeScreen(),
    const Profile(),
    const settings.Settings()
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const CollaboratorHomeScreen();
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
                              builder: (context) => backgroundScreen()),
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
                    // InkWell(
                    //   onTap: () {
                    //     // Navigator.push(
                    //     //   context,
                    //     //   MaterialPageRoute(builder: (context) => NewPostPage()),
                    //     // );
                    //   },
                    //   child: const ListTile(
                    //     leading: Icon(Icons.post_add, color: Colors.white),
                    //     title: Text(
                    //       'New Post',
                    //       style: TextStyle(fontSize: 18, color: Colors.white),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      padding: const EdgeInsets.all(30),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          shape: const CircleBorder(),
          backgroundColor:
              const Color(0xFFFD5336), // Explicitly set to orange here
          child: const Icon(
            Icons.add,
            size: 30,
          ), // Move the `child` property to the end
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: isDarkMode? TColors.light: TColors.dark,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          height: 50,
          child: SingleChildScrollView(
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
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
                          setState(() {
                            currentScreen = AnnouncementScreen(
                                repository:
                                    announcementRepository); // Pass the repository here
                            currentTap = 1;
                          });
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

                  //Right tap bar Icons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MaterialButton(
                        minWidth: 30,
                        onPressed: () {
                          setState(() {
                            currentScreen = const settings.Settings();
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
                          final state =
                              context.read<AuthenticationBloc>().state;

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
                            // If the user is not authenticated, you can handle that case
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("User not authenticated")),
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
        ));
  }
}
