// Path: lib/features/profile/repository/project_idea_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_profile_model.dart';

class ProjectIdeaRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CollaboratorProfileModel?> fetchCollaborator(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('collaborators').doc(userId).get();
    if (doc.exists) {
      return CollaboratorProfileModel.fromMap(
          doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }

  // Other methods for project ideas...
}
