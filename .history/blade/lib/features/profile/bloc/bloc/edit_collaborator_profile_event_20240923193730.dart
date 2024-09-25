// Path: lib/features/profile/bloc/edit_collaborator_profile_event.dart

import 'package:equatable/equatable.dart';

abstract class EditCollaboratorProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveCollaboratorProfile extends EditCollaboratorProfileEvent {
  final CollaboratorProfileModel profile;

  SaveCollaboratorProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class FetchSkills extends EditCollaboratorProfileEvent {}
