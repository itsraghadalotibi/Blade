import 'package:cloud_firestore/cloud_firestore.dart';
import 'announcement_model.dart'; // Ensure correct path to the model

class AnnouncementRepository {
  final FirebaseFirestore firestore;

  // Constructor accepting the Firestore instance
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
