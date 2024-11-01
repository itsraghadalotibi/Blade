import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_view.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/bloc/authentication_state.dart';
import 'features/authentication/src/authentication_repository.dart';
import 'features/notification/src/NotificationService.dart';
import 'features/profile/bloc/repository/profile_repository.dart';
class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final NotificationService notificationService = NotificationService();

  @override
  void dispose() {
    // Clean up the notification listener
    notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticationRepository = AuthenticationRepository();
    final profileRepository = ProfileRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authenticationRepository),
        RepositoryProvider.value(value: profileRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        )..add(AppStarted()),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              // Start listening to notifications for the authenticated user
              notificationService.listenToFirebaseNotifications(state.user.uid);
            }
          },
          child: const AppView(),
        ),
      ),
    );
  }
}