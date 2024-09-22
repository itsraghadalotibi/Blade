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

// class Idea {
//   final String title;
//   final String description;
//   final int maxMembers;
//   final List<String> members;  // List of member IDs
//   final List<String> skills;   // List of skills required for the idea

//   Idea({
//     required this.title,
//     required this.description,
//     required this.maxMembers,
//     required this.members,
//     required this.skills,
//   });

//   // Factory constructor to create an Idea from Firestore data
//   factory Idea.fromMap(Map<String, dynamic> data) {
//     return Idea(
//       title: data['title'] ?? '',
//       description: data['description'] ?? '',
//       maxMembers: data['maxMembers'] ?? 0,
//       members: List<String>.from(data['members'] ?? []),  // Ensure members is a List<String>
//       skills: data['skills'] != null && data['skills'] is List  // Check if skills is a List
//           ? List<String>.from(data['skills'])  // Convert to List<String>
//           : [],  // Default to an empty list if not
//     );
//   }
// }

// class Collaborator {
//   final String uid;
//   final String firstName;
//   final String lastName;
//   final String profilePhotoUrl;
//   final List<String> skills;  // Collaborator's skills

//   Collaborator({
//     required this.uid,
//     required this.firstName,
//     required this.lastName,
//     required this.profilePhotoUrl,
//     required this.skills,
//   });

//   // Factory constructor to create a Collaborator from Firestore data
//   factory Collaborator.fromMap(Map<String, dynamic> data) {
//     return Collaborator(
//       uid: data['uid'] ?? '',
//       firstName: data['firstName'] ?? '',
//       lastName: data['lastName'] ?? '',
//       profilePhotoUrl: data['profilePhotoUrl'] ?? '',
//       skills: data['skills'] != null && data['skills'] is List
//           ? List<String>.from(data['skills'])  // Ensure skills is a List<String>
//           : [],  // Default to an empty list if not
//     );
//   }
// }



// class Member {
//   final String name;
//   final List<String> skills;  // Filtered list of skills that match the idea's skills
//   final String imageUrl;

//   Member({
//     required this.name,
//     required this.skills,
//     required this.imageUrl,
//   });
// }

