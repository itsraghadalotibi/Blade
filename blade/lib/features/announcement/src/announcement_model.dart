// src/models/announcement_model.dart

class Idea {
  final String title;
  final String description;
  final int maxMembers;
  final List<String> members;
  final List<String> skills;

  Idea({
    required this.title,
    required this.description,
    required this.maxMembers,
    required this.members,
    required this.skills,
  });

  // Factory constructor to create an Idea from Firestore data
  factory Idea.fromMap(Map<String, dynamic> data) {
    return Idea(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      maxMembers: data['maxMembers'] ?? 0,
      members: List<String>.from(data['members'] ?? []),
      skills: data['skills'] != null && data['skills'] is List
          ? List<String>.from(data['skills'])
          : [],
    );
  }
}

class Collaborator {
  final String uid;
  final String firstName;
  final String lastName;
  final String profilePhotoUrl;
  final List<String> skills;

  Collaborator({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.profilePhotoUrl,
    required this.skills,
  });

  factory Collaborator.fromMap(Map<String, dynamic> data) {
    return Collaborator(
      uid: data['uid'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
      skills: data['skills'] != null && data['skills'] is List
          ? List<String>.from(data['skills'])
          : [],
    );
  }
}

class Member {
  final String name;
  final List<String> skills;
  final String imageUrl;

  Member({
    required this.name,
    required this.skills,
    required this.imageUrl,
  });
}
