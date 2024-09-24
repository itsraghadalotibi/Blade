import 'dart:async';
import 'package:blade_app/utils/helpers/flutter_toast.dart';
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

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    // Check for empty email and password when the button is clicked
    if (event.email.isEmpty) {
      toastInfo(msg: "Email required input");
      emit(AuthenticationUnauthenticated());
      return;
    }
    if (event.password.isEmpty) {
      toastInfo(msg: "Password required input");
      emit(AuthenticationUnauthenticated());
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(event.email)) {
      toastInfo(msg: "Invalid email format.");
      emit(AuthenticationUnauthenticated());
      return;
    }

    // Check if the user is registered
    String? userType = await authenticationRepository.getUserTypeByEmail(event.email);
    if (userType == null) {
      toastInfo(msg: "User is not registered.");
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
          toastInfo(msg: "The password is invalid");
        } else {
          toastInfo(msg: "Login failed: email or password invalid");
        }
        emit(AuthenticationUnauthenticated());
        return;
      } else {
        toastInfo(msg: "Login failed: email or password invalid");
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

  Future<void> _onSignUpCollaboratorRequested(SignUpCollaboratorRequested event, Emitter<AuthenticationState> emit) async {
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

  Future<void> _onSignUpSupporterRequested(SignUpSupporterRequested event, Emitter<AuthenticationState> emit) async {
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

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signOut();
      emit(AuthenticationUnauthenticated());
    } catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  Future<void> _onFetchSkills(
      FetchSkills event, Emitter<AuthenticationState> emit) async {
    emit(SkillsLoading());

    try {
      final List<String> skills = await authenticationRepository.fetchSkills();
      emit(SkillsLoaded(availableSkills: skills));
    } catch (e) {
      emit(SkillsError(error: e.toString()));
    }
  }
}