part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated, unknown } //states the user can be in 

class AuthenticationState extends Equatable {  //Equatable is a package that comes with flutter bloc which allow us to compare objects
  const AuthenticationState._({
    this.status = AuthenticationStatus.unknown,
    this.user

  });

  final AuthenticationStatus status;
  final MyUser? user;

  const AuthenticationState.unknown() : this._(); //return the constructor itself and do nothing
  const AuthenticationState.authenticated(MyUser myUser) :
  this._(status: AuthenticationStatus.authenticated, user: myUser);

  const AuthenticationState.unauthenticated() :
  this._(status: AuthenticationStatus.unauthenticated); //not gonna add a user since we dont have one


  @override
  List<Object?> get props => [status, user];
}