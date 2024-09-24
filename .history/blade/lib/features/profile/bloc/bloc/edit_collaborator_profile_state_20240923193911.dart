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
