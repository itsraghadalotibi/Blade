import 'package:equatable/equatable.dart';
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}

class SignUpCollaboratorRequested extends AuthenticationEvent {
  final CollaboratorModel collaborator;
  final String password;

  SignUpCollaboratorRequested({required this.collaborator, required this.password});

  @override
  List<Object?> get props => [collaborator, password];
}

class SignUpSupporterRequested extends AuthenticationEvent {
  final SupporterModel supporter;
  final String password;

  SignUpSupporterRequested({required this.supporter, required this.password});

  @override
  List<Object?> get props => [supporter, password];
}

class LoginRequested extends AuthenticationEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
