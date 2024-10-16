// Path: lib/features/profile/repository/project_idea_repository.dart

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_profile_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Fetch open ideas by owner (for Ideas tab)
  Future<List<Idea>> fetchIdeasByOwner(String userId, String status) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('ideas')
        .where('status', isEqualTo: status) // Open, Ongoing, or Completed
        .where('members',
            arrayContains: userId) // Check if the user is a member
        .get();

    return snapshot.docs
        .where((doc) =>
            (doc.data()['members'] as List).isNotEmpty &&
            (doc.data()['members'][0] ==
                userId)) // Check if the user is the owner (first member)
        .map((doc) => Idea.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Fetch projects (ongoing/completed) where the user is an owner or a member
  Future<List<Idea>> fetchProjectsByOwnerOrMember(
      String userId, String status) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('ideas')
        .where('status', isEqualTo: status)
        .where('members',
            arrayContains: userId) // User is either owner or member
        .get();

    return snapshot.docs
        .map((doc) => Idea.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Fetch individual collaborator (used in AvatarWidget)
  Future<CollaboratorProfileModel?> fetchCollaborator(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('collaborators').doc(userId).get();
      if (doc.exists) {
        return CollaboratorProfileModel.fromMap(
            doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching collaborator: $e');
      return null;
    }
  }

  // Other methods for interacting with ideas or collaborators...
}
