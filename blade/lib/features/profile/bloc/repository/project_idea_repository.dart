// Path: lib/features/profile/repository/project_idea_repository.dart

import 'package:blade_app/features/announcement/src/announcement_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_profile_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch ideas where the user is the owner (i.e., userId is the first member in the 'members' array)
  Future<List<Idea>> fetchIdeasByOwner(String userId,String status) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('ideas')
          .where('status',isEqualTo: status)
          .where('members',
              arrayContains: userId) // Check if the user is in the members list
          .get();
      final allJoinRequests = (await FirebaseFirestore.instance
          .collection('join_requests')
          .where('status', isEqualTo: "pending")
          .where('ideaId', whereIn: snapshot.docs.map((d)=>d.id).toList())
          .get()).docs;
      // Map Firestore documents to Idea model and filter by the owner (userId at index 0)
      List<Idea> ideas = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final members = List<String>.from(data['members']);

            // Only return ideas where the user is at index 0 (the owner)
            if ((members.isNotEmpty && members[0] == userId) || status != 'open') {
              return Idea(
                id: doc.id,
                status: data['status'],
                title: data['title'],
                description: data['description'],
                skills: List<String>.from(data['skills']),
                members: members,
                maxMembers: data['maxMembers'],
                requestCount: allJoinRequests.where((d)=>d["ideaId"] == doc.id).length
              );
            }
            return null;
          })
          .where((idea) => idea != null)
          .cast<Idea>()
          .toList();

      return ideas;
    } catch (e) {
      print('Error fetching ideas for owner: $e');
      return [];
    }
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
