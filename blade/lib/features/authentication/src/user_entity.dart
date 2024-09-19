abstract class UserEntity {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;

  UserEntity({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
  });
}
