// Updated ProjectRepository
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../announcement/src/announcement_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Collaborator?> getCurrentUser() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null; // User is not authenticated
    }

    DocumentSnapshot snapshot = await _firestore.collection('supporters').doc(uid).get();
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

  Future<List<Idea>> getProjects() async {
    QuerySnapshot snapshot = await _firestore
        .collection('ideas')
        .where('status', whereIn: ['completed', 'ongoing']) // Fetch both completed and ongoing projects
        .get();

    return snapshot.docs.map((doc) {
      return Idea.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
