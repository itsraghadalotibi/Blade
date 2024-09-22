// Path: lib/features/profile/src/collaborator_profile_model.dart

class CollaboratorProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profilePhotoUrl;
  final List<String>?
      skills; // Updated to List<String> to match Firestore array

  CollaboratorProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profilePhotoUrl,
    this.skills,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'skills': skills, // Keep skills as a List
    };
  }

  static CollaboratorProfileModel fromMap(Map<String, dynamic> map) {
    return CollaboratorProfileModel(
      uid: map['uid'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      skills: List<String>.from(
          map['skills'] ?? []), // Convert List<dynamic> to List<String>
    );
  }
}
