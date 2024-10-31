import 'package:blade_app/features/profile/bloc/bloc/profile_view_bloc.dart';
import 'package:blade_app/features/profile/bloc/bloc/profile_view_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:blade_app/features/authentication/bloc/authentication_bloc.dart';
import 'package:blade_app/features/authentication/bloc/authentication_state.dart';
import 'package:blade_app/features/authentication/src/supporter_model.dart';
import 'package:blade_app/features/supporter/home_page/screens/home_page_screen.dart';
import 'package:blade_app/features/profile/bloc/repository/profile_repository.dart';
import 'package:blade_app/features/profile/bloc/screens/supporter_profile_screen.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart' as settings;

class SupporterNavigation extends StatefulWidget {
  const SupporterNavigation({super.key});

  @override
  State<SupporterNavigation> createState() => _SupporterNavigationState();
}

class _SupporterNavigationState extends State<SupporterNavigation> {
  int currentTap = 0;
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen =  HomeScreen(); // Initial screen is the home screen

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageStorage(bucket: bucket, child: currentScreen),
      bottomNavigationBar: BottomAppBar(
        color: isDarkMode ? Colors.black : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        height: 50,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Evenly distribute the icons
          children: <Widget>[
            Expanded(
              child: IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.home,
                  color:
                      currentTap == 0 ? const Color(0xFFFD5336) : Colors.grey,
                ),
                onPressed: () {
                  // Set the home page as the current screen when Home icon is clicked
                  setState(() {
                    currentScreen = HomeScreen();
                    currentTap = 0;
                  });
                },
              ),
            ),
            Expanded(
              child: IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.notifications,
                  color:
                      currentTap == 1 ? const Color(0xFFFD5336) : Colors.grey,
                ),
                onPressed: () {
                  // Navigate to the settings screen when the Notifications icon is clicked
                  setState(() {
                    currentScreen = const settings.Settings();
                    currentTap = 1;
                  });
                },
              ),
            ),
            Expanded(
              child: IconButton(
                iconSize: 30,
                icon: Icon(
                  Icons.person,
                  color:
                      currentTap == 2 ? const Color(0xFFFD5336) : Colors.grey,
                ),
                onPressed: () {
                  final state = context.read<AuthenticationBloc>().state;
                  if (state is AuthenticationAuthenticated) {
                    final user = state.user;

                    if (user is SupporterModel) {
                      setState(() {
                        // Navigate to the profile screen if the user is authenticated
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
                          child: SupporterProfileScreen(userId: user.uid),
                        );
                        currentTap = 2;
                      });
                    }
                  } else {
                    // Show a snack bar if the user is not authenticated
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("User not authenticated"),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
