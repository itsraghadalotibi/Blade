import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

// Define the AuthenticationBloc class which extends Bloc from the flutter_bloc package.
class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  // Declare a UserRepository to interact with user data.
  final UserRepository userRepository;
  // Declare a StreamSubscription to listen to user authentication changes.
  late final StreamSubscription<MyUser?> _userSubscription;

  // Constructor for AuthenticationBloc.
  AuthenticationBloc({
    required this.userRepository  // Required UserRepository instance injected into the bloc.
  }) : super(const AuthenticationState.unknown()) {  // Initial state is set to 'unknown'.
    // Listen to the user stream from UserRepository and handle authentication state changes.
    _userSubscription = userRepository.user.listen((user) {
      // Add an AuthenticationUserChanged event whenever the user stream emits a new user.
      add(AuthenticationUserChanged(user));
    });

    // Define how the bloc should react to AuthenticationUserChanged events.
    on<AuthenticationUserChanged>((event, emit) {
      // Check if the user is not equal to MyUser.empty (indicating a logged-in user).
      if (event.user != MyUser.empty) {
        // Emit an authenticated state with the user information.
        emit(AuthenticationState.authenticated(event.user!));
      } else {
        // Emit an unauthenticated state if the user is MyUser.empty (logged out or no user).
        emit(const AuthenticationState.unauthenticated());
      }
    });
  }

  // Override the close method to clean up resources.
  @override
  Future<void> close() {
    // Cancel the user subscription when the bloc is closed.
    _userSubscription.cancel();
    // Ensure to call the close method of the super class.
    return super.close();
  }

}
