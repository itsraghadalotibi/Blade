// Path: lib/features/profile/bloc/edit_collaborator_profile_bloc.dart

import 'package:bloc/bloc.dart';
import '../repository/profile_repository.dart';
import 'edit_collaborator_profile_event.dart';
import 'edit_collaborator_profile_state.dart';

class EditCollaboratorProfileBloc
    extends Bloc<EditCollaboratorProfileEvent, EditCollaboratorProfileState> {
  final ProfileRepository profileRepository;

  EditCollaboratorProfileBloc({required this.profileRepository})
      : super(CollaboratorProfileUpdating()) {
    on<SaveCollaboratorProfile>(_onSaveCollaboratorProfile);
    on<FetchSkills>(_onFetchSkills);
  }

  Future<void> _onSaveCollaboratorProfile(SaveCollaboratorProfile event,
      Emitter<EditCollaboratorProfileState> emit) async {
    try {
      await profileRepository.updateCollaboratorProfile(event.profile);
      emit(CollaboratorProfileUpdateSuccess(event.profile));
    } catch (error) {
      emit(CollaboratorProfileUpdateFailure());
    }
  }

  Future<void> _onFetchSkills(
      FetchSkills event, Emitter<EditCollaboratorProfileState> emit) async {
    emit(SkillsLoading());
    try {
      final skills = await profileRepository.getSkills();
      emit(SkillsLoaded(skills));
    } catch (error) {
      emit(SkillsError('Error fetching skills'));
    }
  }
}
