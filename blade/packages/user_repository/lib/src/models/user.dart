import '../entities/entities.dart';

// the class that firbase provide is User class so thats why we have myUser class ans never user
class MyUser {
  String userId;
  String email;
  String name;
  bool hasActiveCart;

  MyUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.hasActiveCart,
  });

  static final empty = MyUser(
    userId: '',
    email: '',
    name: '',
    hasActiveCart: false,
    );
// dealing with sending classes, like transforming classes that are coming from app to map that will go to json map from the db in classes to go inside my app
    MyUserEntity toEntity(){
      return MyUserEntity(
          userId: userId,
          email: email,
          name: name,
          hasActiveCart: hasActiveCart,
      );
    } //going to take myUser object and transform it within myUserEntity object then transform it into ajson map thats going to db


    //having an entry json map from the db then it is transforming the json map within myUserEntity object and myUserEntity object transforms itself into my user obj that we can use within our app
    static MyUser fromEntity(MyUserEntity entity){
      return MyUser(
        userId: entity.userId,
       email: entity.email,
       name: entity.name, 
       hasActiveCart: entity.hasActiveCart
       );
    }

    @override
  String toString(){
      return 'MyUser: $userId, $email, $name, $hasActiveCart';
    }
}