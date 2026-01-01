import 'package:equatable/equatable.dart';

final class AccountState extends Equatable {
  const AccountState._();

  @override
  List<Object?> get props => [];

  const AccountState.initial() : this._();
  AccountState reset() {
    return AccountState._();
  }

  AccountState setState() {
    return AccountState._();
  }

  AccountState.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => {};
}
