// lib/features/profile/src/supporter_profile_model.dart

import 'profile_model.dart';

class SupporterProfileModel extends ProfileModel {
  SupporterProfileModel({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
  }) : super(uid: uid, firstName: firstName, lastName: lastName, email: email);

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  static SupporterProfileModel fromMap(Map<String, dynamic> map) {
    return SupporterProfileModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
    );
  }
}
