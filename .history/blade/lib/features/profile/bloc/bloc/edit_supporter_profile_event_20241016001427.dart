import 'package:equatable/equatable.dart';
import '../src/supporter_profile_model.dart';

abstract class EditSupporterProfileEvent extends Equatable {
  const EditSupporterProfileEvent();

  @override
  List<Object?> get props => [];
}

class SaveSupporterProfile extends EditSupporterProfileEvent {
  final SupporterProfileModel profile; // Define the profile field

  const SaveSupporterProfile(this.profile); // Initialize it via the constructor

  @override
  List<Object?> get props => [profile];
}
