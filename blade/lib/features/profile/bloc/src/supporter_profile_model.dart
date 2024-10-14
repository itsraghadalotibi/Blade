class SupporterProfileModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String? bio;  // Optional field
  final String? profilePhotoUrl;  // Optional field

  SupporterProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.bio,  // Now optional
    this.profilePhotoUrl,  // Now optional
  });

  SupporterProfileModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? bio,
    String? profilePhotoUrl,
  }) {
    return SupporterProfileModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,  // Optional field handling
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,  // Optional field handling
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio ?? '',  // Handle null values
      'profilePhotoUrl': profilePhotoUrl ?? '',  // Handle null values
    };
  }

  factory SupporterProfileModel.fromMap(Map<String, dynamic> map) {
    return SupporterProfileModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      bio: map['bio'],  // Optional, no need for null checks
      profilePhotoUrl: map['profilePhotoUrl'],  // Optional, no need for null checks
    );
  }
}