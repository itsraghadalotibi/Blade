import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';
import '../src/authentication_repository.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository authenticationRepository;

  AuthenticationBloc({required this.authenticationRepository})
      : super(AuthenticationInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<SignUpCollaboratorRequested>(_onSignUpCollaboratorRequested);
    on<SignUpSupporterRequested>(_onSignUpSupporterRequested);
    on<LoggedOut>(_onLoggedOut);
  }

  Future<void> _onAppStarted(
    AppStarted event, Emitter<AuthenticationState> emit) async {
  emit(AuthenticationLoading());

  try {
    final isSignedIn = authenticationRepository.isSignedIn();
    if (await isSignedIn) {
      final user = await authenticationRepository.getUser();
      emit(AuthenticationAuthenticated(user: user));
    } else {
      emit(AuthenticationUnauthenticated());
    }
  } catch (error) {
    emit(AuthenticationFailure(error: error.toString()));
  }
}


  Future<void> _onLoggedIn(
      LoggedIn event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    final user = await authenticationRepository.getUser();
    emit(AuthenticationAuthenticated(user: user));
  }

  Future<void> _onLoggedOut(
      LoggedOut event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signOut();
      emit(AuthenticationUnauthenticated());
    } catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  Future<void> _onSignUpCollaboratorRequested(SignUpCollaboratorRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await authenticationRepository.signUpCollaborator(
          event.collaborator, event.password);
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationFailure(error: e.toString()));
    }
  }

  Future<void> _onSignUpSupporterRequested(SignUpSupporterRequested event,
      Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await authenticationRepository.signUpSupporter(
          event.supporter, event.password);
      emit(AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationFailure(error: e.toString()));
    }
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await authenticationRepository.signIn(event.email, event.password);
      final user = await authenticationRepository.getUser();
      emit(AuthenticationAuthenticated(user: user));
    } catch (e) {
      emit(AuthenticationFailure(error: e.toString()));
    }
  }
}
