import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../announcement/src/announcement_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Collaborator?> getCurrentUser(String uid) async {
    DocumentSnapshot snapshot = await _firestore.collection('supporters').doc("jXekOPQuiLWofIHWn8YBM3GDqZg1").get();
    
    if (snapshot.exists) {
      return Collaborator.fromMap(snapshot.data() as Map<String, dynamic>);
    } else {
      return null; // Return null if the user does not exist
    }
  }

  Future<List<Collaborator>> getCollaborators() async {
    QuerySnapshot snapshot = await _firestore.collection('collaborators').get();
    return snapshot.docs.map((doc) => Collaborator.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}


class ProjectRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Idea>> getCompletedProjects() async {
    QuerySnapshot snapshot = await _firestore
        .collection('ideas')
        .where('status', isEqualTo: 'completed') // Filter for completed projects
        .get();

    return snapshot.docs.map((doc) {
      // Pass both the data and the document ID to fromMap
      return Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
