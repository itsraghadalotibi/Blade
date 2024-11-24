import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_view.dart';
import 'features/GithubPoints/bloc/git_hub_points_bloc.dart';
import 'features/authentication/bloc/authentication_bloc.dart';
import 'features/authentication/bloc/authentication_event.dart';
import 'features/authentication/bloc/authentication_state.dart';
import 'features/authentication/src/authentication_repository.dart';
import 'features/chat/src/chat_repository.dart';
import 'features/investment_request/src/investment_request_repository.dart';
import 'features/notification/src/NotificationService.dart';
import 'features/profile/bloc/bloc/profile_view_bloc.dart';
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
    final chatRepository = ChatRepository(firestore: FirebaseFirestore.instance);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authenticationRepository),
        RepositoryProvider.value(value: profileRepository), // Provide ProfileRepository
        RepositoryProvider.value(value: investmentRequestRepository),
        RepositoryProvider.value(value: chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // Provide AuthenticationBloc once
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(
              authenticationRepository: authenticationRepository,
            )..add(AppStarted()),
          ),
          // Provide ProfileViewBloc
          BlocProvider<ProfileViewBloc>(
            create: (context) => ProfileViewBloc(
              profileRepository: profileRepository,
            ),
          ),
          // Add other BlocProviders if necessary
                    // Provide GitHubPointsBloc
          BlocProvider<GitHubPointsBloc>(
            create: (context) => GitHubPointsBloc(),
          ),

        ],
        child: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationAuthenticated) {
              // Use uid instead of id for the unique identifier
              notificationService.listenToFirebaseNotifications(state.user.uid);
            }
          },
          child: const AppView(),
        ),
      ),
    );
  }
}