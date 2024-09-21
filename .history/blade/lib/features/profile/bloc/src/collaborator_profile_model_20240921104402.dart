// lib/features/profile/src/collaborator_profile_model.dart

import 'profile_model.dart';

class CollaboratorProfileModel extends ProfileModel {
  final String? bio;
  final String? profilePhotoUrl;
  final String? skills;
  final String? socialMediaLinks;

  // Include 'email' in the constructor and pass it to the base class
  CollaboratorProfileModel({
    required String uid,
    required String firstName,
    required String lastName,
    required String email, // Add the 'email' field here
    this.bio,
    this.profilePhotoUrl,
    this.skills,
    this.socialMediaLinks,
  }) : super(
            uid: uid,
            firstName: firstName,
            lastName: lastName,
            email: email); // Pass 'email' to base class

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email, // Map 'email' field to Firestore
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'skills': skills,
      'socialMediaLinks': socialMediaLinks,
    };
  }

  // When mapping from Firestore document, include 'email' field
  static CollaboratorProfileModel fromMap(Map<String, dynamic> map) {
    return CollaboratorProfileModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'], // Extract 'email' from the Firestore document
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'],
      skills: map['skills'],
      socialMediaLinks: map['socialMediaLinks'],
    );
  }
}
