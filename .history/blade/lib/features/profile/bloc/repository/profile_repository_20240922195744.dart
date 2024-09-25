// Path: lib/features/profile/repository/profile_repository.dart

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
      final data = doc.data() as Map<String, dynamic>;

      // Make sure that 'skills' is a list and not a string
      if (data['skills'] is String) {
        // If 'skills' is stored as a comma-separated string, convert it to a list
        data['skills'] =
            (data['skills'] as String).split(',').map((s) => s.trim()).toList();
      }

      return CollaboratorProfileModel.fromMap(data);
    } else {
      throw Exception('Collaborator profile not found');
    }
  }

  // Fetch supporter profile
  Future<SupporterProfileModel?> getSupporterProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('supporters').doc(userId).get();
      if (doc.exists) {
        return SupporterProfileModel.fromMap(
            doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Supporter profile not found');
      }
    } catch (error) {
      throw Exception('Failed to load supporter profile: $error');
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
