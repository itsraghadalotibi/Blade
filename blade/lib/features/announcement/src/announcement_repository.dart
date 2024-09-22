// src/repository/announcement_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_model.dart';

class AnnouncementRepository {
  final FirebaseFirestore firestore;

  AnnouncementRepository({required this.firestore});

  // Fetch list of ideas from the 'ideas' collection
  Future<List<Idea>> fetchIdeas() async {
    try {
      final snapshot = await firestore.collection('ideas').get();
      return snapshot.docs.map((doc) => Idea.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to load ideas: $e');
    }
  }

  // Fetch a specific collaborator by userId
  Future<Collaborator?> fetchCollaborator(String userId) async {
    try {
      final snapshot = await firestore
          .collection('collaborators')
          .where('uid', isEqualTo: userId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Collaborator.fromMap(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load collaborator: $e');
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'announcement_model.dart';

// class AnnouncementRepository {
//   final FirebaseFirestore firestore;

//   AnnouncementRepository({required this.firestore});

//   // Fetch list of ideas from the 'ideas' collection
//   Future<List<Idea>> fetchIdeas() async {
//     try {
//       final snapshot = await firestore.collection('ideas').get();
//       return snapshot.docs.map((doc) => Idea.fromMap(doc.data())).toList();
//     } catch (e) {
//       throw Exception('Failed to load ideas: $e');
//     }
//   }

//   // Fetch a specific collaborator by userId
// Future<Collaborator?> fetchCollaborator(String userId) async {
//   try {
//     final snapshot = await firestore
//         .collection('collaborators')
//         .where('uid', isEqualTo: userId)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       print('Collaborator data for userId $userId: ${snapshot.docs.first.data()}');  // Log collaborator data
//       return Collaborator.fromMap(snapshot.docs.first.data());
//     }
//     print('No collaborator found for userId: $userId');  // Log if no data found
//     return null;
//   } catch (e) {
//     print('Error fetching collaborator: $e');  // Log the error
//     throw Exception('Failed to load collaborator: $e');
//   }
// }


//   // Fetch members with filtered skills
// Future<List<Member>> fetchMembers(List<String> memberIds, List<String> ideaSkills) async {
//   List<Member> members = [];
//   print('Fetching members for member IDs: $memberIds');  // Log member IDs
//   for (String memberId in memberIds) {
//     final collaborator = await fetchCollaborator(memberId);
//     if (collaborator != null) {
//       print('Collaborator found: ${collaborator.firstName} ${collaborator.lastName}');  // Log collaborator details
//       // Filter the collaborator's skills to only include those that match the idea's skills
//       List<String> filteredSkills = collaborator.skills
//           .where((skill) => ideaSkills.contains(skill))
//           .toList();

//       print('Filtered skills for collaborator: $filteredSkills');  // Log filtered skills

//       // Only add members with matching skills
//       if (filteredSkills.isNotEmpty) {
//         members.add(
//           Member(
//             name: '${collaborator.firstName} ${collaborator.lastName}',
//             skills: filteredSkills,
//             imageUrl: collaborator.profilePhotoUrl,
//           ),
//         );
//       } else {
//         print('No matching skills found for ${collaborator.firstName}');
//       }
//     } else {
//       print('No collaborator found for memberId: $memberId');  // Log if no collaborator found
//     }
//   }
//   return members;
// }

// }
