// Path: features/profile/bloc/edit_collaborator_profile_state.dart

import 'package:equatable/equatable.dart';

abstract class EditCollaboratorProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditCollaboratorProfileInitial extends EditCollaboratorProfileState {}

class CollaboratorProfileUpdateSuccess extends EditCollaboratorProfileState {}

class CollaboratorProfileUpdateFailure extends EditCollaboratorProfileState {}
