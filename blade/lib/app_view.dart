// gonna contain the material app ( colors, bloc builder, authentication bloc builder to redirect the user either to the auth screen or to the app itself)
import 'package:blade_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:blade_app/screens/authentication/welcome_screen.dart';
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
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
          onSurface: Colors.white,
          primary: Color(0xFF148FFF),
          onPrimary: Colors.white,
          secondary: Color(0xFF4FE3C2),
          onSecondary: Colors.white,
          tertiary: Color(0xFFFD5336),
          error: Colors.red,
          outline: Colors.grey
        ),
        ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(builder: (context, state){
        if(state.status == AuthenticationStatus.authenticated){
          return const HomeScreen();
        } else{
          return const WelcomeScreen();
        }
      }
      ),
    );
  }
}
