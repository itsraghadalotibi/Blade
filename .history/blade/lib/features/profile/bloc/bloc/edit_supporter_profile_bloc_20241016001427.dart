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
      await profileRepository.updateSupporterProfile(
          event.profile); // Update profile in repository
      emit(SupporterProfileUpdateSuccess(
          event.profile)); // Emit success state with the updated profile
    } catch (error) {
      emit(
          SupporterProfileUpdateFailure()); // Emit failure state if error occurs
    }
  }
}
