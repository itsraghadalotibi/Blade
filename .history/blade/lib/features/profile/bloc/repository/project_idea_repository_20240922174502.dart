// Path: lib/features/profile/repository/project_idea_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/project_idea_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch ideas where the user is the owner (i.e., userId is the first member in the 'members' array)
  Future<List<Idea>> fetchIdeasByOwner(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('ideas')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['members']);

      // Only return ideas where the user is at index 0 (the owner)
      if (members.isNotEmpty && members[0] == userId) {
        return Idea(
          title: data['title'],
          description: data['description'],
          skills: List<String>.from(data['skills']),
          members: members,
          maxMembers: data['maxMembers'],
        );
      }
      return null;
    }).where((idea) => idea != null).toList();
  }
}// Path: lib/features/profile/repository/project_idea_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/project_idea_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch ideas where the user is the owner (i.e., userId is the first member in the 'members' array)
  Future<List<Idea>> fetchIdeasByOwner(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('ideas')
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final members = List<String>.from(data['members']);

      // Only return ideas where the user is at index 0 (the owner)
      if (members.isNotEmpty && members[0] == userId) {
        return Idea(
          title: data['title'],
          description: data['description'],
          skills: List<String>.from(data['skills']),
          members: members,
          maxMembers: data['maxMembers'],
        );
      }
      return null;
    }).where((idea) => idea != null).toList();
  }
}