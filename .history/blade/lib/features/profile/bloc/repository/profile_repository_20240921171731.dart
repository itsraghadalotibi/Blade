// Path: lib/features/profile/repository/profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_profile_model.dart';
import '../src/supporter_profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch collaborator profile
  Future<CollaboratorProfileModel?> getCollaboratorProfile(
      String userId) async {
    try {
      print(
          'Fetching collaborator profile for userId: $userId'); // Log the userId

      DocumentSnapshot doc =
          await _firestore.collection('collaborators').doc(userId).get();

      if (doc.exists) {
        print(
            'Collaborator profile data: ${doc.data()}'); // Log the profile data

        return CollaboratorProfileModel.fromMap(
            doc.data() as Map<String, dynamic>);
      } else {
        print(
            'Collaborator profile not found for userId: $userId'); // Log if not found
        throw Exception('Collaborator profile not found');
      }
    } catch (error) {
      print('Error fetching collaborator profile: $error'); // Log any errors
      throw Exception('Failed to load collaborator profile: $error');
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
