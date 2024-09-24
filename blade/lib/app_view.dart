// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
import 'package:blade_app/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blade_app/features/authentication/screens/forgetPassword_screen.dart';
import 'features/authentication/screens/collaborator_sign_up_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/supporter_sign_up_screen.dart';
import 'features/authentication/screens/welcome_screen.dart';
import 'features/authentication/src/authentication_repository.dart';
import 'utils/constants/Navigation/navigation.dart';
import 'utils/theme/theme.dart';
class AppView extends StatelessWidget{
  const AppView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blade App',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: FutureBuilder(
        future: _checkAuthentication(context), // Check auth state
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data == true) {
            return const Navigation(); // Authenticated user
          } else {
            return IntroScreen(); // Unauthenticated user
          }
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            final String userType = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => LoginScreen(userType: userType),
            );

          case '/collaboratorSignUp':
            return MaterialPageRoute(builder: (_) => const CollaboratorSignUpScreen());

          case '/supporterSignUp':
            return MaterialPageRoute(builder: (_) => const SupporterSignUpScreen());
            
            case '/forgetPassword':
            return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()); // Add this case

          case '/home':
            return MaterialPageRoute(builder: (_) => const Navigation());

          default:
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());
        }
      },
    );
  }

  Future<bool> _checkAuthentication(BuildContext context) async {
    final isSignedIn = await context.read<AuthenticationRepository>().isSignedIn();
    return isSignedIn;
  }
}



