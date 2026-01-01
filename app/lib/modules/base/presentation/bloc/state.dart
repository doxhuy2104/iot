import 'package:equatable/equatable.dart';

final class State extends Equatable {
  const State._();

  @override
  List<Object?> get props => [];

  const State.initial() : this._();
  State reset() {
    return State._();
  }

  State setState() {
    return State._();
  }

  State.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => {};
}
