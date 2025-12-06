import 'package:equatable/equatable.dart';

sealed class Event extends Equatable {
  const Event();

  @override
  List<Object> get props => [];
}

class SignInRequest extends Event {
}

class SignOutRequest extends Event {
  const SignOutRequest();
}
