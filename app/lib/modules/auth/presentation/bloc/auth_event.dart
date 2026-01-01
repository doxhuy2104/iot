import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequest extends AuthEvent {
  final String username;
  final String password;

  const SignInRequest({required this.username, required this.password});
}

class SignUpRequest extends AuthEvent {
  final String email;
  final String username;
  final String password;

  const SignUpRequest({
    required this.email,
    required this.username,
    required this.password,
  });
}

class SignOutRequest extends AuthEvent {
  const SignOutRequest();
}
