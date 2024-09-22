import 'dart:io';
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

abstract class AuthenticationEvent {}

class AppStarted extends AuthenticationEvent {}

class FetchSkills extends AuthenticationEvent {}

class LoginRequested extends AuthenticationEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});
}

class SignUpCollaboratorRequested extends AuthenticationEvent {
  final CollaboratorModel collaborator;
  final String password;
  final File? profileImage; // Add this parameter

  SignUpCollaboratorRequested({
    required this.collaborator,
    required this.password,
    this.profileImage, // Optional profile image
  });
}

class SignUpSupporterRequested extends AuthenticationEvent {
  final SupporterModel supporter;
  final String password;
  final File? profileImage; // Add this parameter

  SignUpSupporterRequested({
    required this.supporter,
    required this.password,
    this.profileImage, // Optional profile image
  });
}

class LoggedOut extends AuthenticationEvent {}

