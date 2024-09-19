// lib/features/profile/repository/profile_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_profile_model.dart';
import '../src/profile_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('collaborators').doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return CollaboratorProfileModel.fromMap(data);
      } else {
        throw Exception('Profile not found');
      }
    } catch (error) {
      throw Exception('Failed to load profile: $error');
    }
  }

  // Add this method to handle profile updates in Firebase
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      // Since profile is a CollaboratorProfileModel, update the corresponding document in 'collaborators'
      await _firestore
          .collection('collaborators')
          .doc(profile.uid)
          .update(profile.toMap());
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }
}
