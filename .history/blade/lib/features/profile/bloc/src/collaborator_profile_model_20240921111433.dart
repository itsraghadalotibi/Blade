// lib/features/profile/src/collaborator_profile_model.dart

class CollaboratorProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? bio;
  final String? profilePhotoUrl;
  final String? skills; // Collaborator-specific field
  final String? socialMediaLinks; // Optional

  CollaboratorProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.bio,
    this.profilePhotoUrl,
    this.skills,
    this.socialMediaLinks,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'skills': skills,
      'socialMediaLinks': socialMediaLinks,
    };
  }

  static CollaboratorProfileModel fromMap(Map<String, dynamic> map) {
    return CollaboratorProfileModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'],
      skills: map['skills'],
      socialMediaLinks: map['socialMediaLinks'],
    );
  }
}
