import 'package:equatable/equatable.dart';
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final dynamic user; // Can be CollaboratorModel or SupporterModel

  AuthenticationAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthenticationUnauthenticated extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String error;

  AuthenticationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
