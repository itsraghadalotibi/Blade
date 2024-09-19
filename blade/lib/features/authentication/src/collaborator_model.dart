import '../src/user_entity.dart';

class CollaboratorModel extends UserEntity {
  final String? skills;
  final String? bio;
  final String? profilePhotoUrl;
  final String? socialMediaLinks;

  CollaboratorModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    this.skills,
    this.bio,
    this.profilePhotoUrl,
    this.socialMediaLinks,
  }) : super(uid: uid, email: email, firstName: firstName, lastName: lastName);

  CollaboratorModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? skills,
    String? bio,
    String? profilePhotoUrl,
    String? socialMediaLinks,
  }) {
    return CollaboratorModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      socialMediaLinks: socialMediaLinks ?? this.socialMediaLinks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'skills': skills,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
      'socialMediaLinks': socialMediaLinks,
    };
  }

  factory CollaboratorModel.fromMap(Map<String, dynamic> map) {
    return CollaboratorModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      skills: map['skills'],
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'],
      socialMediaLinks: map['socialMediaLinks'],
    );
  }
}
