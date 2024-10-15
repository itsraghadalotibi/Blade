import 'package:equatable/equatable.dart';
import '../src/supporter_profile_model.dart';

abstract class EditSupporterProfileState extends Equatable {
  const EditSupporterProfileState();

  @override
  List<Object?> get props => [];
}

class SupporterProfileUpdating extends EditSupporterProfileState {}

class SupporterProfileUpdateSuccess extends EditSupporterProfileState {
  final SupporterProfileModel updatedProfile; // Define updatedProfile field

  const SupporterProfileUpdateSuccess(
      this.updatedProfile); // Pass profile in constructor

  @override
  List<Object?> get props => [updatedProfile];
}

class SupporterProfileUpdateFailure extends EditSupporterProfileState {}
