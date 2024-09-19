// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
// lib/app_view.dart
// lib/app_view.dart
import 'package:flutter/material.dart';
import 'features/authentication/screens/collaborator_sign_up_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/supporter_sign_up_screen.dart';
import 'features/authentication/screens/welcome_screen.dart';
import 'home_screen.dart';

class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blade App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(userType: 'collaborator'), // Adjust as needed
        '/collaboratorSignUp': (context) => const CollaboratorSignUpScreen(),
        '/supporterSignUp': (context) => const SupporterSignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}


