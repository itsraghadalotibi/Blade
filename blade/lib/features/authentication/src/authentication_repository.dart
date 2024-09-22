import 'dart:io';
import 'package:blade_app/utils/helpers/flutter_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  AuthenticationRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? firebaseStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  // Sign up Collaborator with optional profile image
  Future<void> signUpCollaborator(
      CollaboratorModel collaborator, String password, {File? profileImage}) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: collaborator.email,
      password: password,
    );

    String? profilePhotoUrl;

    if (profileImage != null) {
      profilePhotoUrl = await uploadProfileImage(userCredential.user!.uid, profileImage);
    } else {
      profilePhotoUrl = 'https://firebasestorage.googleapis.com/v0/b/blade-87cf7.appspot.com/o/profile_images%2F360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=0db52e6c-f589-451d-9d22-c81190c123a1';
    }

    collaborator = collaborator.copyWith(
      uid: userCredential.user!.uid,
      profilePhotoUrl: profilePhotoUrl,
    );

    await _firestore.collection('collaborators').doc(collaborator.uid).set(collaborator.toMap());
  }

  // Sign up Supporter with optional profile image
  Future<void> signUpSupporter(
      SupporterModel supporter, String password, {File? profileImage}) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: supporter.email,
      password: password,
    );

    String? profilePhotoUrl;

    if (profileImage != null) {
      profilePhotoUrl = await uploadProfileImage(userCredential.user!.uid, profileImage);
    } else {
      profilePhotoUrl = 'https://firebasestorage.googleapis.com/v0/b/blade-87cf7.appspot.com/o/profile_images%2F360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=0db52e6c-f589-451d-9d22-c81190c123a1';
    }

    supporter = supporter.copyWith(
      uid: userCredential.user!.uid,
      profilePhotoUrl: profilePhotoUrl,
    );

    await _firestore.collection('supporters').doc(supporter.uid).set(supporter.toMap());
  }

  // Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      Reference storageRef = _firebaseStorage.ref().child('profile_images/$userId.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() {});
      String downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Sign in method
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out method
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    final _currentUser = _firebaseAuth.currentUser;
    return _currentUser != null;
  }

  // Get current user data
  Future<dynamic> getUser() async {
    final User? firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser != null) {
      DocumentSnapshot collaboratorDoc = await _firestore
          .collection('collaborators')
          .doc(firebaseUser.uid)
          .get();

      if (collaboratorDoc.exists) {
        return CollaboratorModel.fromMap(collaboratorDoc.data() as Map<String, dynamic>);
      }

      DocumentSnapshot supporterDoc = await _firestore
          .collection('supporters')
          .doc(firebaseUser.uid)
          .get();

      if (supporterDoc.exists) {
        return SupporterModel.fromMap(supporterDoc.data() as Map<String, dynamic>);
      }

      toastInfo(msg: "User not registered as Collaborator or Supporter");
    } else {
      toastInfo(msg: "The user is not registered");
    }

    return null;
  }

  // Get user type by email
  Future<String?> getUserTypeByEmail(String email) async {
    try {
      QuerySnapshot collaboratorSnapshot = await _firestore
          .collection('collaborators')
          .where('email', isEqualTo: email)
          .get();

      if (collaboratorSnapshot.docs.isNotEmpty) {
        return 'collaborator';
      }

      QuerySnapshot supporterSnapshot = await _firestore
          .collection('supporters')
          .where('email', isEqualTo: email)
          .get();

      if (supporterSnapshot.docs.isNotEmpty) {
        return 'supporter';
      }
    } catch (e) {
      throw Exception('Failed to get user type: $e');
    }

    return null; // Unknown user type
  }

  // Save collaborator data
  Future<void> saveCollaboratorData(CollaboratorModel collaborator) async {
    await _firestore.collection('collaborators').doc(collaborator.uid).set(collaborator.toMap());
  }

  // Save supporter data
  Future<void> saveSupporterData(SupporterModel supporter) async {
    await _firestore.collection('supporters').doc(supporter.uid).set(supporter.toMap());
  }

  // Fetch skills from Firestore
  Future<List<String>> fetchSkills() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('skills').get();
      final List<String> skills = snapshot.docs
          .map((doc) => doc.get('name') as String)
          .toList()
          .cast<String>();
      return skills;
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }
}
