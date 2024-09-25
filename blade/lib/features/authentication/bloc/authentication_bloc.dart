import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../src/authentication_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationRepository;

  AuthenticationBloc({required this.authenticationRepository})
      : super(AuthenticationInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpCollaboratorRequested>(_onSignUpCollaboratorRequested);
    on<SignUpSupporterRequested>(_onSignUpSupporterRequested);
    on<LoggedOut>(_onLoggedOut);
    on<FetchSkills>(_onFetchSkills); 
  }

  // Handle App Started Event
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      final isSignedIn = await authenticationRepository.isSignedIn();
      if (isSignedIn) {
        final user = await authenticationRepository.getUser();
        emit(AuthenticationAuthenticated(user: user));
      } else {
        emit(AuthenticationUnauthenticated());
      }
    } catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  // Handle Login Event
  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    // Check for empty email and password when the button is clicked
    if (event.email.isEmpty) {
      emit(AuthenticationFailure(error: "Email is required"));
      emit(AuthenticationUnauthenticated());
      return;
    }
    if (event.password.isEmpty) {
      emit(AuthenticationFailure(error: "Password is required"));
      emit(AuthenticationUnauthenticated());
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(event.email)) {
      emit(AuthenticationFailure(error: "Invalid email format"));
      emit(AuthenticationUnauthenticated());
      return;
    }

    // Check if the user is registered
    String? userType = await authenticationRepository.getUserTypeByEmail(event.email);
    if (userType == null) {
      emit(AuthenticationFailure(error: "User is not registered"));
      emit(AuthenticationUnauthenticated());
      return;
    }

    // Attempt to sign in the user
    try {
      await authenticationRepository.signIn(event.email, event.password);
    } catch (error) {
      // Handle sign-in errors
      if (error is FirebaseAuthException) {
        if (error.code == 'wrong-password') {
          emit(AuthenticationFailure(error: "Invalid password"));
        } else {
          emit(AuthenticationFailure(error: "Login failed: email or password invalid"));
        }
        emit(AuthenticationUnauthenticated());
        return;
      } else {
        emit(AuthenticationFailure(error: "Login failed: email or password invalid"));
        emit(AuthenticationUnauthenticated());
        return;
      }
    }

    // If sign-in was successful, get the user
    final user = await authenticationRepository.getUser();

    // Check user type against the expected user type
    if (userType != event.userType) {
      emit(AuthenticationFailure(error: "Incorrect user type."));
      emit(AuthenticationUnauthenticated());
      return;
    }

    emit(AuthenticationAuthenticated(user: user));
  }

  // Handle Collaborator Sign-Up Event
  Future<void> _onSignUpCollaboratorRequested(
      SignUpCollaboratorRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signUpCollaborator(
        event.collaborator,
        event.password,
        profileImage: event.profileImage,
      );
      await authenticationRepository.signOut();
      emit(AuthenticationUnauthenticated());
    } catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  // Handle Supporter Sign-Up Event
  Future<void> _onSignUpSupporterRequested(
      SignUpSupporterRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signUpSupporter(
        event.supporter,
        event.password,
        profileImage: event.profileImage,
      );
      await authenticationRepository.signOut();
      emit(AuthenticationUnauthenticated());
    } catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  // Handle Log Out Event
  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signOut();
      emit(AuthenticationUnauthenticated());
    } catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  // Handle Fetch Skills Event
  Future<void> _onFetchSkills(FetchSkills event, Emitter<AuthenticationState> emit) async {
    emit(SkillsLoading());

    try {
      final List<String> skills = await authenticationRepository.fetchSkills();
      emit(SkillsLoaded(availableSkills: skills));
    } catch (e) {
      emit(SkillsError(error: e.toString()));
    }
  }
}
