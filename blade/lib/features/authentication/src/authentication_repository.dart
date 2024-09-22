import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage; // Add Firebase Storage instance

  AuthenticationRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    FirebaseStorage? firebaseStorage,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance; // Initialize Firebase Storage

  // Sign up Collaborator with optional profile image
  Future<void> signUpCollaborator(
      CollaboratorModel collaborator, String password, {File? profileImage}) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: collaborator.email,
      password: password,
    );

    String? profilePhotoUrl;

    // If profile image is provided, upload it
    if (profileImage != null) {
      profilePhotoUrl = await uploadProfileImage(userCredential.user!.uid, profileImage);
    }else{
      profilePhotoUrl = 'https://firebasestorage.googleapis.com/v0/b/blade-87cf7.appspot.com/o/profile_images%2F360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg?alt=media&token=0db52e6c-f589-451d-9d22-c81190c123a1';
    }

    // Update collaborator model with UID and profilePhotoUrl
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

    // If profile image is provided, upload it
    if (profileImage != null) {
      profilePhotoUrl = await uploadProfileImage(userCredential.user!.uid, profileImage);
    }else{
      profilePhotoUrl = 'gs://blade-87cf7.appspot.com/profile_images/360_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg';
    }


    // Update supporter model with UID and profilePhotoUrl
    supporter = supporter.copyWith(
      uid: userCredential.user!.uid,
      profilePhotoUrl: profilePhotoUrl,
    );

    await _firestore.collection('supporters').doc(supporter.uid).set(supporter.toMap());
  }

  // Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      Reference storageRef = _firebaseStorage.ref().child('profile_images/$userId.jpg');

      // Upload the file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait until the upload completes
      await uploadTask.whenComplete(() {});

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  // Sign in method remains the same
  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Sign out method remains the same
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user data
  Future<dynamic> getUser() async {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      // Check if user is a collaborator
      DocumentSnapshot doc =
          await _firestore.collection('collaborators').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return CollaboratorModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      // Check if user is a supporter
      doc = await _firestore.collection('supporters').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return SupporterModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Save collaborator data
  Future<void> saveCollaboratorData(CollaboratorModel collaborator) async {
    await _firestore.collection('collaborators').doc(collaborator.uid).set(collaborator.toMap());
  }

  // Save supporter data
  Future<void> saveSupporterData(SupporterModel supporter) async {
    await _firestore.collection('supporters').doc(supporter.uid).set(supporter.toMap());
  }

  /// Fetch skills from Firestore
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

