// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)

import 'package:blade_app/features/notification/screens/NotificationCenterScreen.dart';
import 'package:blade_app/intro_screen.dart';
import 'package:blade_app/utils/constants/Navigation/settings.dart';
import 'package:blade_app/utils/constants/Navigation/supporterNav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blade_app/features/authentication/screens/forgetPassword_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/authentication/screens/collaborator_sign_up_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/supporter_sign_up_screen.dart';
import 'features/authentication/screens/welcome_screen.dart';
import 'features/authentication/src/authentication_repository.dart';
import 'features/authentication/src/collaborator_model.dart';
import 'features/authentication/src/supporter_model.dart';
import 'features/profile/bloc/screens/supporter_profile_screen.dart';
import 'utils/constants/Navigation/navigation.dart';
import 'features/supporter/home_page/screens/home_page_screen.dart';

import 'utils/theme/theme.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  Future<Widget> _checkInitialScreen(BuildContext context) async {
    final authRepo = context.read<AuthenticationRepository>();
    final isSignedIn = await authRepo.isSignedIn();
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

    if (!hasSeenIntro) {
      return const IntroScreen();
    } else if (isSignedIn) {
      final user = await authRepo.getUser();

      if (user is CollaboratorModel) {
        // await authRepo.updateCollaboratorToken(user.uid);
        return const Navigation();
      } else if (user is SupporterModel) {
        return const SupporterNavigation();
      } else {
        return const WelcomeScreen(); // Unknown user type
      }
    } else {
      return const WelcomeScreen(); // Unauthenticated user
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blade App',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: FutureBuilder<Widget>(
        future: _checkInitialScreen(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const WelcomeScreen();
          }
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/welcome':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          case '/login':
            final String userType = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => LoginScreen(userType: userType),
            );
          case '/collaboratorSignUp':
            return MaterialPageRoute(
                builder: (_) => const CollaboratorSignUpScreen());
          case '/supporterSignUp':
            return MaterialPageRoute(
                builder: (_) => const SupporterSignUpScreen());
          case '/forgetPassword':
            return MaterialPageRoute(
                builder: (_) => const ForgetPasswordScreen());
          case '/collaboratorHome':
            return MaterialPageRoute(
              builder: (_) => const Navigation(),
            );
          case '/supporterHome':
            return MaterialPageRoute(
              builder: (_) => const SupporterNavigation(),
            );
          case '/notificationCenter':
            return MaterialPageRoute(
                builder: (_) => const NotificationCenterScreen(
                      userId: '',
                    ));
          case '/supporterProfile':
            final String userId =
                settings.arguments as String; // Pass the user ID dynamically
            return MaterialPageRoute(
              builder: (_) => SupporterProfileScreen(userId: userId),
            );
          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
      },
    );
  }
}
