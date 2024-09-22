// Path: features/profile/bloc/edit_supporter_profile_event.dart

import 'package:equatable/equatable.dart';
import '../src/supporter_profile_model.dart';

abstract class EditSupporterProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SaveSupporterProfile extends EditSupporterProfileEvent {
  final SupporterProfileModel updatedProfile;

  SaveSupporterProfile(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}
