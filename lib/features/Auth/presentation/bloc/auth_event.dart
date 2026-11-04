abstract class AuthEvent {}

class SignInUser extends AuthEvent{

  final String email;
  final String password;

  SignInUser({required this.email,required this.password});
}

class ResetPassword extends AuthEvent{

  final String email;
  ResetPassword({required this.email});
}