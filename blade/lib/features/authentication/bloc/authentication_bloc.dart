import 'dart:async';

import 'package:blade_app/utils/helpers/flutter_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
  }

  Future<void> _onAppStarted(
      AppStarted event, Emitter<AuthenticationState> emit) async {

    emit(AuthenticationLoading());
    //credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: event.email.toString(), password: event.pass)
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
  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      // Check for empty email and password before proceeding
      if (event.email.isEmpty) {
        toastInfo(msg: "Email required input");
        return;
      }
      if (event.password.isEmpty) {
        toastInfo(msg: "Password required input");
        return;
      }

      // Try to sign in
      await authenticationRepository.signIn(event.email, event.password);
      final user = await authenticationRepository.getUser();
      emit(AuthenticationAuthenticated(user: user));

    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        toastInfo(msg: "User does not exist");

      } else if (error.code == 'wrong-password') {
        toastInfo(msg: "The password is invalid");}
      else if (error.code == 'invalid-email') {
        toastInfo(msg: "The email format is invalid");
              } else {

        toastInfo(msg: "Login failed email or password invalid");
     // emit(AuthenticationFailure(error: error.message.toString()));
      }
    } catch (error) {
      // Generic error handling for other exceptions
      emit(AuthenticationFailure(error: "An error occurred. Please try again."));
    }
  }
  Future<void> _onSignUpCollaboratorRequested(
      SignUpCollaboratorRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signUpCollaborator(
        event.collaborator,
        event.password,
        profileImage: event.profileImage, // Pass the profile image
      );
      emit(AuthenticationUnauthenticated());
    }
    catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
  }

  Future<void> _onSignUpSupporterRequested(
      SignUpSupporterRequested event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      await authenticationRepository.signUpSupporter(
        event.supporter,
        event.password,
        profileImage: event.profileImage, // Pass the profile image
      );
      emit(AuthenticationUnauthenticated());
    }on FirebaseAuthException  catch(error){
      if(error.code == 'user-not-found'){
        toastInfo(msg: "user not exit");
      }
      if(error.code== 'wrong-password'){
        toastInfo(msg: "the password is invaide");
      }
    }catch (error) {
      emit(AuthenticationFailure(error: error.toString()));
    }
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
}
