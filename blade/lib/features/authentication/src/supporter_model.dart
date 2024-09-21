class SupporterModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String bio;
  final String profilePhotoUrl; // Add this field

  // Constructor
  SupporterModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.profilePhotoUrl,
  });

  // Implement copyWith method
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

  // toMap and fromMap methods
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

  static SupporterModel fromMap(Map<String, dynamic> map) {
    return SupporterModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      bio: map['bio'],
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
    );
  }
}
