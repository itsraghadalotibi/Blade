import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'edit_supporter_profile_event.dart';
import 'edit_supporter_profile_state.dart';
import '../src/supporter_profile_model.dart';

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
      // Attempt to update the profile in the repository
      await profileRepository.updateSupporterProfile(event.updatedProfile);

      // Emit success with the updated profile
      emit(SupporterProfileUpdateSuccess(event.updatedProfile));
    } catch (error) {
      // Emit failure with the error message
      emit(SupporterProfileUpdateFailure('Failed to update profile: $error'));
    }
  }
}
