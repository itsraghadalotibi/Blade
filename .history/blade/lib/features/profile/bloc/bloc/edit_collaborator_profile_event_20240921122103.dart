// Path: features/profile/bloc/edit_collaborator_profile_event.dart

import 'package:equatable/equatable.dart';
import '../src/collaborator_profile_model.dart';

abstract class EditCollaboratorProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveCollaboratorProfile extends EditCollaboratorProfileEvent {
  final CollaboratorProfileModel updatedProfile;

  SaveCollaboratorProfile(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}
