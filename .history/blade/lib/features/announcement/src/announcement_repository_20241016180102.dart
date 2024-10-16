import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_model.dart';

class AnnouncementRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AnnouncementRepository();

  // Method to create a new Idea in Firestore with the creator as the first member
  Future<void> createIdea(Idea idea, String creatorId) async {
    try {
      if (idea.members.isEmpty || idea.members[0] != creatorId) {
        idea.members.insert(0, creatorId);
      }

      await firestore.collection('ideas').add(idea.toMap());
    } catch (e) {
      throw Exception('Failed to create idea: $e');
    }
  }

  // Fetch ideas where status='open' and not owned or already a member by the current user
  Future<List<Idea>> fetchIdeas(String currentUserId) async {
    try {
      // Fetch open ideas
      final snapshot = await firestore
          .collection('ideas')
          .where('status', isEqualTo: 'open') // Filter for status='open'
          .get();

      // Fetch join requests for the current user
      final querySnapshot = await firestore
          .collection('join_requests')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Map over the ideas and filter them
      return snapshot.docs
          .where((doc) {
            final members = List<String>.from(doc['members'] ?? []);
            return members.isEmpty ||
                (members[0] != currentUserId && !members.contains(currentUserId)) &&
                members.length < doc["maxMembers"];
          })
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Check if the user has a join request for this idea
            final isPendingOrAccepted = querySnapshot.docs.any((d) {
              return d['ideaId'] == doc.id &&
                     (d['status'] == 'pending' || d['status'] == 'accepted');
            });

            // Set isJoined as true if there's a pending or accepted request
            return Idea.fromMap(data, doc.id)
              ..isJoined = isPendingOrAccepted;
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
      throw Exception('Failed to update idea');
    }
  }

  // Send join request to an idea
  Future<void> sendJoinRequest(Idea idea, String currentUserId) async {
    try {
      await firestore.collection('join_requests').add({
        "ideaId": idea.id,
        "userId": currentUserId,
        'status': 'pending',
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to send join request: $e');
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
          .map((doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
          .map((doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
          .map((doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to load ideas by skill: $e');
    }
  }

  // Add a member to an existing idea
  Future<void> addMemberToIdea(String? ideaId, String memberId) async {
    try {
      await firestore.collection('ideas').doc(ideaId).update({
        'members': FieldValue.arrayUnion([memberId])
      });
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  // Remove a member from an existing idea
  Future<void> removeMemberFromIdea(String? ideaId, String memberId) async {
    try {
      await firestore.collection('ideas').doc(ideaId).update({
        'members': FieldValue.arrayRemove([memberId])
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

  // Update idea status
  Future<void> updateIdeaStatus(String ideaId, String newStatus) async {
    try {
      await firestore.collection('ideas').doc(ideaId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update idea status');
    }
  }

  // Stream ideas based on the current user
  Stream<List<Idea>> streamIdeas(String currentUserId) {
    return firestore.collection('ideas')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.where((doc) {
            final members = List<String>.from(doc['members'] ?? []);
            return members.isEmpty ||
                (members[0] != currentUserId && !members.contains(currentUserId)) &&
                members.length < doc["maxMembers"];
          }).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Idea.fromMap(data, doc.id);
          }).toList();
        });
  }

  // Update project status
  Future<void> updateProjectStatus(String projectId, String newStatus) async {
    try {
      await firestore.collection('ideas').doc(projectId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw Exception('Failed to update project status: $e');
    }
  }

  // Accept a join request and hide the join button for the user
  Future<void> acceptJoinRequest(Idea idea, String userId) async {
    try {
      final requestRef = await firestore
          .collection('join_requests')
          .where('ideaId', isEqualTo: idea.id)
          .where('userId', isEqualTo: userId)
          .get();

      if (requestRef.docs.isNotEmpty) {
        await requestRef.docs.first.reference.update({'status': 'accepted'});

        await firestore.collection('ideas').doc(idea.id).update({
          'members': FieldValue.arrayUnion([userId])
        });

        final int maxMembers = idea.maxMembers;
        final int currentMembers = idea.members.length;
        final bool isFull = currentMembers == maxMembers;

        if (isFull) {
          await updateProjectStatus(idea.id!, "ongoing");
          idea.status = "ongoing";
        }
      }
    } catch (e) {
      throw Exception('Failed to accept join request.');
    }
  }

  // Reject join request
  Future<void> rejectJoinRequest(String ideaId, String userId) async {
    try {
      final requestRef = await firestore
          .collection('join_requests')
          .where('ideaId', isEqualTo: ideaId)
          .where('userId', isEqualTo: userId)
          .get();

      if (requestRef.docs.isNotEmpty) {
        await requestRef.docs.first.reference.update({'status': 'rejected'});
      }
    } catch (e) {
      throw Exception('Failed to reject join request.');
    }
  }
}
