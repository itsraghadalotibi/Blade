// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
import 'package:flutter/material.dart';
import 'package:blade_app/features/authentication/screens/forgetPassword_screen.dart';
import 'features/authentication/screens/collaborator_sign_up_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/authentication/screens/supporter_sign_up_screen.dart';
import 'features/authentication/screens/welcome_screen.dart';
import 'home_screen.dart';
import 'utils/constants/Navigation/navigation.dart';
import 'utils/theme/theme.dart';
class AppView extends StatelessWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blade App',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const WelcomeScreen());

          case '/login':
            // Extract the userType argument and pass it to LoginScreen
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
}


