// lib/features/profile/repository/profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_profile_model.dart';
import '../src/supporter_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch collaborator profile
  Future<CollaboratorProfileModel?> getCollaboratorProfile(
      String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('collaborators').doc(userId).get();
    if (doc.exists) {
      return CollaboratorProfileModel.fromMap(
          doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('Collaborator profile not found');
    }
  }

  // Fetch supporter profile
  Future<SupporterProfileModel?> getSupporterProfile(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('supporters').doc(userId).get();
    if (doc.exists) {
      return SupporterProfileModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      throw Exception('Supporter profile not found');
    }
  }

  // Update collaborator profile
  Future<void> updateCollaboratorProfile(
      CollaboratorProfileModel profile) async {
    await _firestore
        .collection('collaborators')
        .doc(profile.uid)
        .update(profile.toMap());
  }

  // Update supporter profile
  Future<void> updateSupporterProfile(SupporterProfileModel profile) async {
    await _firestore
        .collection('supporters')
        .doc(profile.uid)
        .update(profile.toMap());
  }
}
