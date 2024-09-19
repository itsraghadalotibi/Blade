// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
import 'package:blade_app/screens/authentication/login_screen.dart';
import 'package:blade_app/screens/authentication/sign_up/student_sign_up.dart';
import 'package:blade_app/screens/authentication/sign_up/supporter_sign_up.dart';
import 'package:blade_app/screens/authentication/welcome_screen.dart';
import 'package:blade_app/screens/home/home_screen.dart';
import 'package:blade_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Assuming you're using Bloc for authentication
import 'blocs/authentication_bloc/authentication_bloc.dart';

<<<<<<< Updated upstream
=======
import 'screens/home/home_screen.dart';
import 'screens/newPost/backgroundPost.dart';
import 'screens/newPost/post.dart';
>>>>>>> Stashed changes

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blade',
      themeMode: ThemeMode.dark,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
<<<<<<< Updated upstream
      initialRoute: '/',
      routes: {
        // Root route that checks authentication state
        '/': (context) => BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, state) {
                if (state.status == AuthenticationStatus.authenticated) {
                  return const HomeScreen(); // Authenticated users go to HomeScreen
                } else {
                  return const WelcomeScreen(); // Unauthenticated users go to WelcomeScreen
                }
              },
            ),
        // Login screen, passed the userType argument
        '/login': (context) => LoginScreen(userType: ModalRoute.of(context)!.settings.arguments as String),
        // Student sign-up screen
        '/signup-student': (context) => const StudentSignUpScreen(),
        // Supporter sign-up screen
        '/signup-supporter': (context) => const SupporterSignUpScreen(),
      },
=======
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (context, state){
        if(state.status == AuthenticationStatus.authenticated){
          return const HomeScreen();
        } else{
          //retutn const WlcomeScreen
          return backgroundScreen();
        }
      }
      ),
>>>>>>> Stashed changes
    );
  }
}
