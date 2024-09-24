import 'package:blade_app/features/profile/bloc/repository/profile_repository.dart';
import 'package:blade_app/features/profile/bloc/repository/project_idea_repository.dart';
import 'package:blade_app/features/profile/bloc/screens/collaborator_profile_screen.dart';
import 'package:blade_app/home_screen.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart' as settings;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase import
import '../../../features/announcement/screens/announcement_screen.dart';
import '../../../features/newPost/screens/backgroundPost.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  // Initialize necessary repositories
  final projectIdeaRepository = ProjectIdeaRepository();
  final profileRepository = ProfileRepository();

  int currentTap = 0;

  // Screens for the bottom navigation
  final List<Widget> screen = [
    const HomeScreen(),
    const settings.Settings(),
    // Collaborator Profile Screen (make sure userId is dynamically set)
    CollaboratorProfileScreen(userId: 'currentUserId'),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const HomeScreen(); // Initial Screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: currentScreen, // Display the current selected screen
      ),
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
                  InkWell(
                    onTap: () {
                      // Add functionality if needed
                    },
                    child: const ListTile(
                      leading: Icon(Icons.post_add, color: Colors.white),
                      title: Text(
                        'New Post',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
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
        backgroundColor: const Color(0xFFFD5336), // Orange color for the FAB
        child: const Icon(Icons.add, size: 30), // Add Icon in FAB
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 50,
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
                        currentScreen = const HomeScreen();
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
                  const SizedBox(width: 15), // Adjust the width for spacing
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = AnnouncementScreen(
                            repository:
                                projectIdeaRepository); // Link announcement screen
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
                              : Colors.grey,
                          width: 30,
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  const SizedBox(width: 15),
                  MaterialButton(
                    minWidth: 30,
                    onPressed: () {
                      setState(() {
                        currentScreen = CollaboratorProfileScreen(
                          userId: 'currentUserId', // Pass the correct userId
                        ); // Link to Collaborator Profile
                        currentTap = 3;
                      });
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
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
