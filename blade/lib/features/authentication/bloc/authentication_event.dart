import 'dart:io';
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

abstract class AuthenticationEvent {}

class AppStarted extends AuthenticationEvent {}
class FetchSkills extends AuthenticationEvent {}
class LoginRequested extends AuthenticationEvent {
  final String email;
  final String password;
  final String userType; // Added userType

  LoginRequested({
    required this.email,
    required this.password,
    required this.userType, // Added userType
  });
}

class SignUpCollaboratorRequested extends AuthenticationEvent {
  final CollaboratorModel collaborator;
  final String password;
  final File? profileImage;

  SignUpCollaboratorRequested({
    required this.collaborator,
    required this.password,
    this.profileImage,
  });
}

class SignUpSupporterRequested extends AuthenticationEvent {
  final SupporterModel supporter;
  final String password;
  final File? profileImage;

  SignUpSupporterRequested({
    required this.supporter,
    required this.password,
    this.profileImage,
  });
}

class LoggedOut extends AuthenticationEvent {}
