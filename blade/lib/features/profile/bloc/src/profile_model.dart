// lib/features/profile/src/profile_model.dart

abstract class ProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;

  ProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email, // Constructor includes 'email'
  });

  Map<String, dynamic> toMap();
}
