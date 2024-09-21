class CollaboratorModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> skills; // Changed to List<String>
  final String bio;
  final Map<String, String> socialMediaLinks; // Changed to Map<String, String>
  final String profilePhotoUrl;

  // Constructor
  CollaboratorModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.skills,
    required this.bio,
    required this.socialMediaLinks,
    required this.profilePhotoUrl,
  });

  // Implement copyWith method
  CollaboratorModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    List<String>? skills,
    String? bio,
    Map<String, String>? socialMediaLinks,
    String? profilePhotoUrl,
  }) {
    return CollaboratorModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  // toMap method
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'skills': skills,
      'bio': bio,
      'socialMediaLinks': socialMediaLinks,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  // fromMap method
  static CollaboratorModel fromMap(Map<String, dynamic> map) {
    return CollaboratorModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      skills: List<String>.from(map['skills'] ?? []),
      bio: map['bio'],
      socialMediaLinks: Map<String, String>.from(map['socialMediaLinks'] ?? {}),
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
    );
  }
}

