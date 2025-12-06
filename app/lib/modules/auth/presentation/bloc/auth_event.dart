import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInRequest extends AuthEvent {
  final String? email;
  final String token;
  final String? type;

  const SignInRequest({this.email, required this.token, this.type});
}

class SignOutRequest extends AuthEvent {
  const SignOutRequest();
}
