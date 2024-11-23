import 'package:blade_app/features/project_info/src/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_model.dart';
import 'package:rxdart/rxdart.dart';

class AnnouncementRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  AnnouncementRepository();

  // Method to create a new Idea in Firestore with the creator as the first member
  Future<DocumentReference> createIdea(Idea idea, String creatorId) async {
    try {
      // Ensure the creator is the first member of the idea
      if (idea.members.isEmpty || idea.members[0] != creatorId) {
        idea.members.insert(0, creatorId);
      }
      // Add the new idea to the Firestore collection and return the DocumentReference
      return await firestore.collection('ideas').add(idea.toMap());
    } catch (e) {
      throw Exception('Failed to create idea: $e');
    }
  }

  // Fetch ideas where status='open' and not owned or already a member by the current user
  Future<List<Idea>> fetchIdeas(String currentUserId) async {
    try {
      final snapshot = await firestore
          .collection('ideas')
          .where('status', isEqualTo: 'open') // Filter for status='open'
          .orderBy('title', descending: true)
          .get();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('join_requests')
          .where('userId', isEqualTo: currentUserId)
          .orderBy('title', descending: false)
          .get();

      // Filter ideas to exclude those owned by the current user
      return snapshot.docs.where((doc) {
        final members = List<String>.from(doc['members'] ?? []);
        return members.isEmpty ||
            (members[0] != currentUserId && !members.contains(currentUserId)) &&
                members.length < doc["maxMembers"];
      }).map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Idea.fromMap(data, doc.id)
          // Pass the document ID to fromMap
          ..isJoined = querySnapshot.docs.where((d) {
            return d['ideaId'] == doc.id;
          }).isNotEmpty;
        // set isJoined value
      }).toList();
    } catch (e) {
      throw Exception('Failed to load ideas: $e');
    }
  }

  // Fetch an Idea by its ID
  Future<Idea?> getIdeaById(String ideaId) async {
    try {
      final doc = await firestore.collection('ideas').doc(ideaId).get();
      if (doc.exists && doc.data() != null) {
        final idea = Idea.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
        print('Repo URL: ${idea.repoUrl}'); // Log the repoUrl
        return idea;
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

  // Join to Idea
  Future<void> sendJoinRequest(Idea idea, String cureentUser) async {
    try {
      await firestore.collection('join_requests').add({
        "ideaId": idea.id,
        "userId": cureentUser,
        'status': 'pending',
        'timestamp': Timestamp.now(), // Convert timestamp to DateTime.
      });
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
          .map(
              (doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
          .map(
              (doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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
          .map(
              (doc) => Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id))
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

  // Fetch a specific collaborator by userId
  Future<Collaborator?> fetchCollaboratorOffers(String userId) async {
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
    final ideaRef = firestore.collection('ideas').doc(ideaId);
    final ideaDoc = await ideaRef.get();

    if (ideaDoc.exists) {
      final data = ideaDoc.data() as Map<String, dynamic>;
      final currentStatus = data['status'];

      // Update the status
      await ideaRef.update({
        'status': newStatus,
      });

      // If status changed from 'open' to 'ongoing', create the chat room
      if (currentStatus == 'open' && newStatus == 'ongoing') {
        final members = List<String>.from(data['members'] ?? []);

        // Create the chat room
        await _createChatRoomForProject(ideaId, data['title'], members);
      }
    } else {
      throw Exception('Idea not found');
    }
  } catch (e) {
    print('Error updating idea status: $e');
    throw Exception('Failed to update idea status');
  }
}

// Add this method inside AnnouncementRepository
Future<void> _createChatRoomForProject(String ideaId, String ideaTitle, List<String> members) async {
  try {
    final chatRoomData = {
      'name': '$ideaTitle Group',
      'members': members, // Use 'members' to match the ChatRoom model
      'projectId': ideaId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': null, // Initialize as null
      'lastMessageTime': null, // Initialize as null
      'unreadCounts': {}, // Initialize as an empty map
    };

    // Check if a chat room for this project already exists
    final existingChatRoom = await firestore
        .collection('chatRooms')
        .where('projectId', isEqualTo: ideaId)
        .limit(1)
        .get();

    if (existingChatRoom.docs.isEmpty) {
      // Create the chat room
      final chatRoomRef = await firestore.collection('chatRooms').add(chatRoomData);

      // Optionally, send a system message
      final messageData = {
        'senderId': 'system',
        'text': 'Welcome to the $ideaTitle Group chat!',
        'timestamp': FieldValue.serverTimestamp(),
        'readBy': [],
      };

      // Add the message to the messages subcollection
      await chatRoomRef.collection('messages').add(messageData);

      // Update lastMessage and lastMessageTime in chatRoomData
      await chatRoomRef.update({
        'lastMessage': messageData['text'],
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } else {
      print('Chat room for this project already exists.');
    }
  } catch (e) {
    print('Error creating chat room: $e');
    // Handle the error as needed
  }
}



  Stream<List<Idea>> streamIdeas(String currentUserId) {
    final ideasStream = firestore
        .collection('ideas')
        .where('status', isEqualTo: 'open')
        .orderBy('title', descending: true)
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

    // Stream for 'join_requests' collection
    final joinRequestsStream = firestore
        .collection('join_requests')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc['ideaId'] as String).toList();
    });

    // Combine both streams
    return Rx.combineLatest2<List<Idea>, List<String>, List<Idea>>(
      ideasStream,
      joinRequestsStream,
      (ideas, joinIdeaIds) {
        return ideas.map((idea) {
          // Set isJoined flag based on join requests
          idea.isJoined = joinIdeaIds.contains(idea.id);
          return idea;
        }).toList();
      },
    );
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

  Future<void> acceptJoinRequest(Idea idea, String userId) async {
    try {
      // Update the join request status to "accepted" in Firestore
      final requestRef = await firestore
          .collection('join_requests')
          .where('ideaId', isEqualTo: idea.id)
          .where('userId', isEqualTo: userId)
          .get();

      if (requestRef.docs.isNotEmpty) {
        await requestRef.docs.first.reference.update({'status': 'accepted'});
        // Add the requester as a member of the idea
        await firestore.collection('ideas').doc(idea.id).update({
          'members': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      throw Exception('Failed to accept join request.');
    }
  }

  Future<void> rejectJoinRequest(String ideaId, String userId) async {
    try {
      // Update the join request status to "rejected" in Firestore
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
