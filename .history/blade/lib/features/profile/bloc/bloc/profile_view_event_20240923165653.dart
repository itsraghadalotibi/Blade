// lib/features/profile/bloc/profile_view_event.dart
import 'package:equatable/equatable.dart';

abstract class ProfileViewEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileViewEvent {
  final String userId;

  LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileViewEvent {
  final dynamic
      profile; // Can be CollaboratorProfileModel or SupporterProfileModel

  UpdateProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}
