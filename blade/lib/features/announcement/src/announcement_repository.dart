import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_model.dart';

class AnnouncementRepository {
  final FirebaseFirestore firestore;

  AnnouncementRepository({required this.firestore});

  // Method to create a new Idea in Firestore with the creator as the first member
  Future<void> createIdea(Idea idea, String creatorId) async {
  try {
    // Check if the creatorId is already present in the members list
    if (idea.members.isEmpty || idea.members[0] != creatorId) {
      // Ensure the creator is the first member of the idea
      idea.members.insert(0, creatorId);
    }
    
    await firestore.collection('ideas').add(idea.toMap());
  } catch (e) {
    throw Exception('Failed to create idea: $e');
  }
}

  Future<List<Idea>> fetchIdeas(String currentUserId) async {
    try {
      final snapshot = await firestore
          .collection('ideas')
          .where('status', isEqualTo: 'open') // Filter for status='open'
          .get();

      // Filter ideas to exclude those owned by the current user
      return snapshot.docs
          .where((doc) {
            final members = List<String>.from(doc['members'] ?? []);
            return members.isEmpty || 
                  members[0] != currentUserId && 
                  !members.contains(currentUserId); // Exclude owner's ideas and those where the user is a member
          })
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data, doc.id); // Pass the document ID to fromMap
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load ideas: $e');
    }
  }





  // Fetch an Idea by its ID
  Future<Idea?> getIdeaById(String ideaId) async {
  try {
    final doc = await firestore.collection('ideas').doc(ideaId).get();
    if (doc.exists && doc.data() != null) {
      return Idea.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    }
    return null;
  } catch (e) {
    throw Exception('Failed to load idea: $e');
  }
}

  // Delete an Idea by its ID
  Future<void> deleteIdea(String ideaId) async {
    try {
      await firestore.collection('ideas').doc(ideaId).delete();
    } catch (e) {
      throw Exception('Failed to delete idea: $e');
    }
  }

  // Update an existing Idea by its ID
  Future<void> updateIdea(Idea idea) async {
    try {
      await firestore.collection('ideas').doc(idea.id).update(idea.toMap());
    } catch (e) {
      print('Error updating idea: $e');
      throw Exception('Failed to update idea');
    }
  }

  // Fetch ideas with pagination (limit the number of results)
  Future<List<Idea>> fetchIdeasWithPagination({
    required int limit,
    DocumentSnapshot? lastDoc,
  }) async {
    try {
      Query query = firestore.collection('ideas').limit(limit);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .where((doc) => doc.data() != null) // Ensure the document data is not null
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data, doc.id); // Pass the document ID to fromMap
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load paginated ideas: $e');
    }
  }

  // Fetch ideas by maxMembers
  Future<List<Idea>> fetchIdeasByMaxMembers(int maxMembers) async {
    try {
      final snapshot = await firestore
          .collection('ideas')
          .where('maxMembers', isEqualTo: maxMembers)
          .get();
      return snapshot.docs
          .where((doc) => doc.data() != null) // Ensure the document data is not null
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data, doc.id); // Pass the document ID to fromMap
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load ideas: $e');
    }
  }

  // Fetch ideas by skill
  Future<List<Idea>> fetchIdeasBySkill(String skill) async {
    try {
      final snapshot = await firestore
          .collection('ideas')
          .where('skills', arrayContains: skill)
          .get();
      return snapshot.docs
          .where((doc) => doc.data() != null) // Ensure the document data is not null
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data, doc.id); // Pass the document ID to fromMap
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to load ideas by skill: $e');
    }
  }

  // Add a member to an existing idea
  Future<void> addMemberToIdea(String? ideaId, String memberId) async {
    try {
      await firestore.collection('ideas').doc(ideaId).update({
        'members': FieldValue.arrayUnion([memberId])  // Add memberId to the members array
      });
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  // Remove a member from an existing idea
  Future<void> removeMemberFromIdea(String? ideaId, String memberId) async {
    try {
      await firestore.collection('ideas').doc(ideaId).update({
        'members': FieldValue.arrayRemove([memberId])  // Remove memberId from the members array
      });
    } catch (e) {
      throw Exception('Failed to remove member: $e');
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
  // Add a real-time listener for fetching a collaborator
Stream<Collaborator?> streamCollaborator(String userId) {
  return firestore.collection('collaborators').doc(userId).snapshots().map(
    (snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Collaborator.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    },
  );
}

  Future<void> updateIdeaStatus(String ideaId, String newStatus) async {
  try {
    await firestore.collection('ideas').doc(ideaId).update({
      'status': newStatus,
    });
  } catch (e) {
    print('Error updating idea status: $e');
    throw Exception('Failed to update idea status');
  }
}

  Stream<List<Idea>> streamIdeas(String currentUserId) {
    return firestore.collection('ideas')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final members = List<String>.from(doc['members'] ?? []);
            return members.isEmpty ||
                members[0] != currentUserId &&
                !members.contains(currentUserId); // Filter logic
          }).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data, doc.id); // Pass the document ID to fromMap
          }).toList();
        });
  }

  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    try {
      await firestore.collection('ideas').doc(projectId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update project status: $e');
    }
  }
}
