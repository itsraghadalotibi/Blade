// Path: features/profile/bloc/edit_supporter_profile_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'edit_supporter_profile_event.dart';
import 'edit_supporter_profile_state.dart';

class EditSupporterProfileBloc
    extends Bloc<EditSupporterProfileEvent, EditSupporterProfileState> {
  final ProfileRepository profileRepository;

  EditSupporterProfileBloc({required this.profileRepository})
      : super(EditSupporterProfileInitial()) {
    on<SaveSupporterProfile>(_onSaveSupporterProfile);
  }

  Future<void> _onSaveSupporterProfile(SaveSupporterProfile event,
      Emitter<EditSupporterProfileState> emit) async {
    try {
      await profileRepository.updateSupporterProfile(event.updatedProfile);
      emit(SupporterProfileUpdateSuccess());
    } catch (error) {
      emit(SupporterProfileUpdateFailure());
    }
  }
}
