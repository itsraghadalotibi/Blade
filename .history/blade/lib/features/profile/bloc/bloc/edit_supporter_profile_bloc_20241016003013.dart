import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'edit_supporter_profile_event.dart';
import 'edit_supporter_profile_state.dart';

class EditSupporterProfileBloc
    extends Bloc<EditSupporterProfileEvent, EditSupporterProfileState> {
  final ProfileRepository profileRepository;

  EditSupporterProfileBloc({required this.profileRepository})
      : super(SupporterProfileUpdating()) {
    on<SaveSupporterProfile>(_onSaveSupporterProfile);
  }

  Future<void> _onSaveSupporterProfile(SaveSupporterProfile event,
      Emitter<EditSupporterProfileState> emit) async {
    try {
      // Call the repository to update the profile
      await profileRepository.updateSupporterProfile(event.profile);
      // Emit success state after updating the profile
      emit(SupporterProfileUpdateSuccess(event.profile));
    } catch (error) {
      // Emit failure state if something goes wrong
      emit(SupporterProfileUpdateFailure());
    }
  }
}
