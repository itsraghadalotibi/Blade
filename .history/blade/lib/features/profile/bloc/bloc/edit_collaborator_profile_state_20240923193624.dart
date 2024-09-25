// Path: lib/features/profile/bloc/edit_collaborator_profile_state.dart

import 'package:equatable/equatable.dart';
import '../src/collaborator_profile_model.dart';

abstract class EditCollaboratorProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CollaboratorProfileUpdateSuccess extends EditCollaboratorProfileState {
  final CollaboratorProfileModel updatedProfile;

  CollaboratorProfileUpdateSuccess(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}

class CollaboratorProfileUpdateFailure extends EditCollaboratorProfileState {}

class CollaboratorProfileUpdating extends EditCollaboratorProfileState {}

class SkillsLoaded extends EditCollaboratorProfileState {
  final List<String> availableSkills;

  SkillsLoaded(this.availableSkills);

  @override
  List<Object?> get props => [availableSkills];
}

class SkillsError extends EditCollaboratorProfileState {
  final String error;

  SkillsError(this.error);

  @override
  List<Object?> get props => [error];
}
