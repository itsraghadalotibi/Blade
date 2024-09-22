// Path: features/profile/bloc/edit_supporter_profile_state.dart

import 'package:equatable/equatable.dart';

abstract class EditSupporterProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditSupporterProfileInitial extends EditSupporterProfileState {}

class SupporterProfileUpdateSuccess extends EditSupporterProfileState {}

class SupporterProfileUpdateFailure extends EditSupporterProfileState {}
