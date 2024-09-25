// Path: lib/features/profile/bloc/edit_collaborator_profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import '../src/collaborator_profile_model.dart';
import 'edit_collaborator_profile_event.dart';
import 'edit_collaborator_profile_state.dart';

class EditCollaboratorProfileBloc
    extends Bloc<EditCollaboratorProfileEvent, EditCollaboratorProfileState> {
  final ProfileRepository profileRepository;

  EditCollaboratorProfileBloc({required this.profileRepository})
      : super(CollaboratorProfileUpdating()) {
    on<SaveCollaboratorProfile>(_onSaveCollaboratorProfile);
  }

  Future<void> _onSaveCollaboratorProfile(SaveCollaboratorProfile event,
      Emitter<EditCollaboratorProfileState> emit) async {
    try {
      // Call the repository to update the collaborator profile
      await profileRepository.updateCollaboratorProfile(event.profile);
      emit(CollaboratorProfileUpdateSuccess(
          event.profile)); // Emit updated profile
    } catch (error) {
      emit(CollaboratorProfileUpdateFailure());
    }
  }
}
