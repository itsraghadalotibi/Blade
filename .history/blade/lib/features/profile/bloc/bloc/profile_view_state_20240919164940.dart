// lib/features/profile/bloc/profile_view_state.dart

import 'package:equatable/equatable.dart';
import '../src/profile_model.dart';

abstract class ProfileViewState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileViewState {}

class ProfileLoaded extends ProfileViewState {
  final ProfileModel profile;

  ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileViewState {}

class ProfileError extends ProfileViewState {
  final String message;

  ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
