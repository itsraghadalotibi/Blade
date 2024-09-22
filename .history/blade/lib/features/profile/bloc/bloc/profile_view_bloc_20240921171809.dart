// Path: lib/features/profile/bloc/profile_view_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'profile_view_event.dart';
import 'profile_view_state.dart';
import '../src/collaborator_profile_model.dart';
import '../src/supporter_profile_model.dart';

class ProfileViewBloc extends Bloc<ProfileViewEvent, ProfileViewState> {
  final ProfileRepository profileRepository;

  ProfileViewBloc({required this.profileRepository}) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileViewState> emit) async {
    try {
      print('Loading profile for userId: ${event.userId}'); // Log the userId

      // Try to fetch collaborator profile first
      try {
        final profile =
            await profileRepository.getCollaboratorProfile(event.userId);
        if (profile != null) {
          print('Collaborator profile loaded successfully'); // Log success
          emit(ProfileLoaded(profile));
          return;
        }
      } catch (e) {
        print(
            'Collaborator profile not found, trying supporter...'); // Log if collaborator not found
      }

      // Fetch supporter profile if collaborator is not found
      final profile = await profileRepository.getSupporterProfile(event.userId);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('Profile not found.'));
      }
    } catch (error) {
      print('Error loading profile: $error'); // Log any errors
      emit(ProfileError('Failed to load profile.'));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<ProfileViewState> emit) async {
    try {
      // Update based on the profile type (Collaborator or Supporter)
      if (event.profile is CollaboratorProfileModel) {
        await profileRepository.updateCollaboratorProfile(
            event.profile as CollaboratorProfileModel);
      } else if (event.profile is SupporterProfileModel) {
        await profileRepository
            .updateSupporterProfile(event.profile as SupporterProfileModel);
      }
      emit(ProfileUpdated());
    } catch (error) {
      emit(ProfileError('Failed to update profile.'));
    }
  }
}
