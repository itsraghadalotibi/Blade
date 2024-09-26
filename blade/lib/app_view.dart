// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
import 'package:blade_app/intro_screen.dart';
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
import 'features/collaborator/screens/collaborator_home_screen.dart';
import 'features/supporter/screens/supporter_home_screen.dart';
import 'utils/constants/Navigation/navigation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import 'utils/theme/theme.dart';
class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

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
        return const Navigation();
      } else if (user is SupporterModel) {
        return const SupporterHomeScreen();
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
              builder: (_) => const SupporterHomeScreen(),
            );
          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
            
        }
      },
    );
  }
}


