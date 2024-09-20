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

  factory Idea.fromMap(Map<String, dynamic> data) {
    return Idea(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      maxMembers: data['maxMembers'] ?? 0,
      members: List<String>.from(data['members']),
      skills: List<String>.from(data['skills']),
    );
  }
}

class Collaborator {
  final String uid;
  final String firstName;
  final String lastName;
  final String profilePhotoUrl;

  Collaborator({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.profilePhotoUrl,
  });

  factory Collaborator.fromMap(Map<String, dynamic> data) {
    return Collaborator(
      uid: data['uid'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? '',
    );
  }
}
