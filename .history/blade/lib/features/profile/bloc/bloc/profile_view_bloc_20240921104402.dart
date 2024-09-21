// lib/features/profile/bloc/profile_view_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/profile_repository.dart';
import 'profile_view_event.dart';
import 'profile_view_state.dart';

class ProfileViewBloc extends Bloc<ProfileViewEvent, ProfileViewState> {
  final ProfileRepository profileRepository;

  ProfileViewBloc({required this.profileRepository}) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileViewState> emit) async {
    try {
      final profile = await profileRepository.getProfile(event.userId);
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
      await profileRepository.updateProfile(event.profile);
      emit(ProfileUpdated());
    } catch (error) {
      emit(ProfileError('Failed to update profile.'));
    }
  }
}
