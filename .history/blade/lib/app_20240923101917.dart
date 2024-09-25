// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_view.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/src/authentication_repository.dart';
import 'features/profile/bloc/repository/profile_repository.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticationRepository = AuthenticationRepository();
    final profileRepository = ProfileRepository(); // Add ProfileRepository

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authenticationRepository),
        RepositoryProvider.value(
            value: profileRepository), // Provide ProfileRepository
      ],
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        )..add(AppStarted()),
        child: const AppView(),
      ),
    );
  }
}
