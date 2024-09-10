import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:user_repository/user_repository.dart';

class FirebaseUserRepo implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final usersCollection = FirebaseFirestore.instance.collection('users');

  FirebaseUserRepo({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

    @override
// Stream getter to observe user authentication state and fetch user data from Firestore.
Stream<MyUser?> get user{
  // Listen to the auth state changes in Firebase Authentication.
  return _firebaseAuth.authStateChanges().flatMap((firebaseUser) async*{
    // Check if the Firebase user is null, indicating no user is logged in.
    if (firebaseUser == null) {
      // If no user is logged in, emit a default MyUser.empty object.
      yield MyUser.empty;
    } else {
      // If a user is logged in, fetch the user's detailed data from Firestore.
      yield await usersCollection
        // Access the document corresponding to the user's UID.
        .doc(firebaseUser.uid)
        .get()
        // Once the document is fetched, transform the data into a MyUser instance.
        .then((value) => MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
        // The '!' asserts that data() will not return null, safe only if you're certain of data presence.
    }
  });
}



   @override
  Future<void> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  @override
// Defines an asynchronous function 'signUp' that returns a Future of MyUser type.
Future<MyUser> signUp(MyUser myUser, String password) async {
    try {
        // Attempts to create a new user with an email and password.
        UserCredential user = await _firebaseAuth.createUserWithEmailAndPassword(
            email: myUser.email,  
            password: password     
        );

        // Sets the userId of the MyUser object to the UID from the newly created Firebase user.
        myUser.userId = user.user!.uid;
        // Returns the updated MyUser object with the userId set.
        return myUser;
    } catch (e) {
        // Logs any errors that occur during the sign-up process.
        log(e.toString());
        // Rethrows the caught exception to be handled by the caller of the function.
        rethrow;
    }
}



  @override
  Future<void> logOut() async {
    await _firebaseAuth.signOut();
  }

  @override
// Defines an asynchronous function that sets or updates user data in Firestore.
Future<void> setUserData(MyUser myUser) async {
    try {
        // Attempts to set the user data in Firestore.
        // Accesses the document in the Firestore 'usersCollection' corresponding to the user's ID.
        await usersCollection 
            .doc(myUser.userId)  // Specifies the document path using the userId from MyUser object.
            .set(myUser.toEntity().toDocument());  // Converts MyUser object to a Firestore document format and sets it in the database.
    } catch (e) {
        // If an error occurs during the Firestore operation, log the error.
        log(e.toString());  // Logs the error to the console or a logging service.
        // Rethrows the caught exception to be handled by the caller of the function.
        rethrow;  // Allows further handling of the error outside this function, maintaining error visibility.
    }
}

@override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


@override
  Future<MyUser> getMyUser(String myUserId) async{
    try{
      return usersCollection.doc(myUserId).get().then((value) => 
        MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!))
      );
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }


}