import 'package:equatable/equatable.dart';
import 'package:app/core/models/user_model.dart';

final class AuthState extends Equatable {
  final UserModel? user;
  final String? email;

  const AuthState._({this.user, this.email});

  @override
  List<Object?> get props => [user.hashCode, email.hashCode];

  const AuthState.initial() : this._();
  AuthState reset() {
    return AuthState._(email: email);
  }

  AuthState setState({UserModel? user, String? email}) {
    return AuthState._(user: user ?? this.user, email: email ?? this.email);
  }

  AuthState.fromJson(Map<String, dynamic> json)
    : user = UserModel.fromJson(json['user']),
      email = json['email'];

  Map<String, dynamic> toJson() => {'user': user?.toJson(), 'email': email};
}
