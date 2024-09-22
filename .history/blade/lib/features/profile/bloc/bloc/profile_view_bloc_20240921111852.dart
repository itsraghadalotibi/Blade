// lib/features/profile/bloc/profile_view_bloc.dart

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
      // Fetch collaborator profile first
      try {
        final profile =
            await profileRepository.getCollaboratorProfile(event.userId);
        if (profile != null) {
          emit(ProfileLoaded(profile));
          return;
        }
      } catch (e) {
        // Continue to fetch supporter profile if not found in collaborators
      }

      // Fetch supporter profile if collaborator profile is not found
      final profile = await profileRepository.getSupporterProfile(event.userId);
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(ProfileError('Profile not found.'));
      }
    } catch (error) {
      emit(ProfileError('Failed to load profile.'));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event, Emitter<ProfileViewState> emit) async {
    try {
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
