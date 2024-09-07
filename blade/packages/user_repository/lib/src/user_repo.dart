// the class we will call within our app, each method will be adding here that we will call inside our bloc 
// not gonna directly call the method itself adds a layer of security as well of clarity,,
// cuz you have a place to write all the methods that are defined with what you should return for every one of them.
import 'models/models.dart';

abstract class UserRepository {
  Stream<MyUser?> get user;

  Future<MyUser> signUp(MyUser myUser, String password);

  Future<void> setUserData(MyUser user);

  Future<void> signIn(String email, String password);
  
  Future<void> logOut();

}
// *** feel free to edit the parameters ***
// we will implement these methods within the firebase_user_repo.dart