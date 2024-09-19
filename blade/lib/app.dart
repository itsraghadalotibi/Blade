// like a repository that we want throughout the entire process of the app (as notification bloc) and going to redirect to app view file
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_view.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/src/authentication_repository.dart';


class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authenticationRepository = AuthenticationRepository();

    return RepositoryProvider.value(
      value: authenticationRepository,
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        )..add(AppStarted()),
        child: const AppView(),
      ),
    );
  }
}
