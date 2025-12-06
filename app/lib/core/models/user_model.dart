import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? userId;
  final String? avatar;
  final String? username;
  final String? accessToken;
  final String? email;
  final String? loginType;

  const UserModel({
    this.userId,
    this.avatar,
    this.username,
    this.accessToken,
    this.email,
    this.loginType,
  });

  static fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? userId = mapData['userId'];
    final String? avatar = mapData['avatar'];
    final String? username = mapData['username'];
    final String? accessToken = mapData['accessToken'];
    final String? email = mapData['email'];
    final String? loginType = mapData['loginType'];

    return UserModel(
      userId: userId,
      avatar: avatar,
      username: username,
      accessToken: accessToken,
      email: email,
      loginType: loginType,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'avatar': avatar,
    'username': username,
    'accessToken': accessToken,
    'email': email,
    'loginType': loginType,
  };

  UserModel copyWith({
    int? userId,
    String? avatar,
    String? username,
    String? accessToken,
    String? email,
    String? loginType,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      accessToken: accessToken ?? this.accessToken,
      email: email ?? this.email,
      loginType: loginType ?? loginType,
    );
  }

  @override
  List<Object?> get props => [userId];

  @override
  String toString() {
    return 'User: id:$userId, avatar: $avatar, username: $username, accessToken: $accessToken, email: $email, loginType:$loginType';
  }
}
