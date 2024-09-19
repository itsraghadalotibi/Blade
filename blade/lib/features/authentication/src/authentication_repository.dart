import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../src/collaborator_model.dart';
import '../src/supporter_model.dart';

class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthenticationRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> signUpCollaborator(CollaboratorModel collaborator, String password) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: collaborator.email,
      password: password,
    );

    collaborator = collaborator.copyWith(uid: userCredential.user!.uid);

    await _firestore
        .collection('collaborators')
        .doc(collaborator.uid)
        .set(collaborator.toMap());
  }

  Future<void> signUpSupporter(SupporterModel supporter, String password) async {
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: supporter.email,
      password: password,
    );

    supporter = supporter.copyWith(uid: userCredential.user!.uid);

    await _firestore
        .collection('supporters')
        .doc(supporter.uid)
        .set(supporter.toMap());
  }

  Future<void> signIn(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    return _firebaseAuth.currentUser != null;
  }

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
}
