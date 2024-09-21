// Path: features/profile/bloc/edit_collaborator_profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'edit_collaborator_profile_event.dart';
import 'edit_collaborator_profile_state.dart';
import '../src/collaborator_profile_model.dart';

class EditCollaboratorProfileBloc
    extends Bloc<EditCollaboratorProfileEvent, EditCollaboratorProfileState> {
  final ProfileRepository profileRepository;

  EditCollaboratorProfileBloc({required this.profileRepository})
      : super(EditCollaboratorProfileInitial()) {
    on<SaveCollaboratorProfile>(_onSaveCollaboratorProfile);
  }

  Future<void> _onSaveCollaboratorProfile(SaveCollaboratorProfile event,
      Emitter<EditCollaboratorProfileState> emit) async {
    try {
      await profileRepository.updateCollaboratorProfile(event.updatedProfile);
      emit(CollaboratorProfileUpdateSuccess());
    } catch (error) {
      emit(CollaboratorProfileUpdateFailure());
    }
  }
}
