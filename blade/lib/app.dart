// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_view.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/bloc/authentication_state.dart';
import 'features/authentication/src/authentication_repository.dart';
import 'features/investment_request/src/investment_request_repository.dart';
import 'features/notification/src/NotificationService.dart';
import 'features/profile/bloc/repository/profile_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticationRepository = AuthenticationRepository();
    final profileRepository = ProfileRepository(); // Add ProfileRepository
    final investmentRequestRepository = InvestmentRequestRepository();
    final NotificationService notificationService =
        NotificationService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authenticationRepository),
        RepositoryProvider.value(
            value: profileRepository), // Provide ProfileRepository
        RepositoryProvider.value(value: investmentRequestRepository),
      ],
      child: BlocProvider(
        create: (context) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
        )..add(AppStarted()),
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              // Start listening for notifications when authenticated
              notificationService.listenToFirebaseNotifications(state.user.id);
            }
          },
          child: const AppView(),
        ),
      ),
    );
  }
}
