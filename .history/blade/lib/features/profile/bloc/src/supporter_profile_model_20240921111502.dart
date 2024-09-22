// lib/features/profile/src/supporter_profile_model.dart
class SupporterProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;
  final String? profilePhotoUrl; // Common with CollaboratorProfileModel

  SupporterProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    this.profilePhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  static SupporterProfileModel fromMap(Map<String, dynamic> map) {
    return SupporterProfileModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'],
    );
  }
}
