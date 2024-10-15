class SupporterProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? profilePhotoUrl;

  SupporterProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.bio,
    this.profilePhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  static SupporterProfileModel fromMap(Map<String, dynamic> map) {
    return SupporterProfileModel(
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'],
    );
  }
}
