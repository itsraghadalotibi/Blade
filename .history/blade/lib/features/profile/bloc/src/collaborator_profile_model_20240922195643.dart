// Path: lib/features/profile/src/collaborator_profile_model.dart

class CollaboratorProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profilePhotoUrl;
  final List<String>? skills; // Ensure this is a list

  CollaboratorProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profilePhotoUrl,
    this.skills,
  });

  // Convert from Firestore document (Map) to CollaboratorProfileModel
  static CollaboratorProfileModel fromMap(Map<String, dynamic> map) {
    return CollaboratorProfileModel(
      uid: map['uid'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      // Ensure skills is a list. If it's a string, we need to handle that case.
      skills: (map['skills'] as List<dynamic>?)
              ?.map((skill) => skill as String)
              .toList() ??
          [],
    );
  }

  // Convert CollaboratorProfileModel to a Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'skills': skills ?? [],
    };
  }
}
