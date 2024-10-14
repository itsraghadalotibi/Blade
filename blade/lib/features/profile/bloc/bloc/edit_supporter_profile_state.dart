import '../src/supporter_profile_model.dart';

abstract class EditSupporterProfileState {}

class EditSupporterProfileInitial extends EditSupporterProfileState {}

class SupporterProfileUpdateSuccess extends EditSupporterProfileState {
  final SupporterProfileModel profile;

  SupporterProfileUpdateSuccess(this.profile);
}

class SupporterProfileUpdateFailure extends EditSupporterProfileState {
  final String error;

  SupporterProfileUpdateFailure(this.error);
}
