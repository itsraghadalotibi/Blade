// Path: lib/features/profile/src/collaborator_profile_model.dart
class CollaboratorProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profilePhotoUrl;
  final List<String>? skills; // Should be a List<String>
  final Map<String, String>? socialMediaLinks; // Social media links

  CollaboratorProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
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
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'skills': skills,
      'socialMediaLinks': socialMediaLinks, // Include social media links
    };
  }

  static CollaboratorProfileModel fromMap(Map<String, dynamic> map) {
    return CollaboratorProfileModel(
      uid: map['uid'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      bio: map['bio'] as String?,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      // Ensure 'skills' is parsed as a List<String>
      skills: (map['skills'] != null)
          ? List<String>.from(map['skills'] as List<dynamic>)
          : [],
      socialMediaLinks: (map['socialMediaLinks'] != null)
          ? Map<String, String>.from(map['socialMediaLinks'] as Map)
          : {},
    );
  }
}
