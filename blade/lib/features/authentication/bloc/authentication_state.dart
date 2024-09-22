import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final dynamic user;

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
}class SkillsLoading extends AuthenticationState {}

class SkillsLoaded extends AuthenticationState {
  final List<String> availableSkills;

  SkillsLoaded({required this.availableSkills});

  @override
  List<Object?> get props => [availableSkills];
}

class SkillsError extends AuthenticationState {
  final String error;

  SkillsError({required this.error});

  @override
  List<Object?> get props => [error];
}

