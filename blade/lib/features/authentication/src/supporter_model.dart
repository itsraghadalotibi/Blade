import '../src/user_entity.dart';

class SupporterModel extends UserEntity {
  final String? bio;
  final String? profilePhotoUrl;

  SupporterModel({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    this.bio,
    this.profilePhotoUrl,
  }) : super(uid: uid, email: email, firstName: firstName, lastName: lastName);

  SupporterModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? bio,
    String? profilePhotoUrl,
  }) {
    return SupporterModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  factory SupporterModel.fromMap(Map<String, dynamic> map) {
    return SupporterModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'],
    );
  }
}
