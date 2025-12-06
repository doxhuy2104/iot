import 'package:equatable/equatable.dart';

sealed class ZoneEvent extends Equatable {
  const ZoneEvent();

  @override
  List<Object> get props => [];
}

class SignInRequest extends ZoneEvent {
}

class SignOutRequest extends ZoneEvent {
  const SignOutRequest();
}
