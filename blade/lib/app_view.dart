// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
import 'package:blade_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:blade_app/screens/authentication/sign_up_screen.dart';
import 'package:blade_app/screens/authentication/welcome_screen.dart';
import 'package:blade_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/home/home_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blade',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state.status == AuthenticationStatus.authenticated) {
              return const HomeScreen(); // Authenticated users go to HomeScreen
            } else {
              return const WelcomeScreen(); // Unauthenticated users go to WelcomeScreen
            }
          },
        ),
        '/register': (context) => const RegisterScreen(), // Define the RegisterScreen route
      },
    );
  }
}
