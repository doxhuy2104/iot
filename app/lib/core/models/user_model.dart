import 'package:equatable/equatable.dart';

/// Map với enum `User.UserRole` trong backend (USER, ADMIN)
enum UserRole {
  user,
  admin;

  static UserRole? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toUpperCase();
    switch (normalized) {
      case 'USER':
        return UserRole.user;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return null;
    }
  }

  String get backendName {
    switch (this) {
      case UserRole.user:
        return 'USER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }
}

class UserModel extends Equatable {
  /// id trong backend (user_id)
  final int? userId;

  /// Các field phục vụ app (profile / auth)
  final String? avatar;
  final String? username;
  final String? token;
  final String? email;
  final String? loginType;

  /// Các field map trực tiếp với entity User backend
  final String? fullName;
  final String? phone;
  final UserRole? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;

  const UserModel({
    this.userId,
    this.avatar,
    this.username,
    this.token,
    this.email,
    this.loginType,
    this.fullName,
    this.phone,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  static UserModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? userId = mapData['user_id'] ?? mapData['userId'];
    final String? avatar = mapData['avatar'];
    final String? username = mapData['username'];
    final String? token = mapData['token'] ?? mapData['access_token'];
    final String? email = mapData['email'];
    final String? loginType = mapData['loginType'];

    final String? fullName =
        mapData['full_name'] ?? mapData['fullName'] ?? mapData['name'];
    final String? phone = mapData['phone'];
    final UserRole? role = UserRole.fromString(mapData['role']);
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;
    final DateTime? updatedAt = mapData['updated_at'] != null
        ? (mapData['updated_at'] is DateTime
              ? mapData['updated_at']
              : DateTime.tryParse(mapData['updated_at'].toString()))
        : null;
    final bool? isActive =
        mapData['is_active'] ?? mapData['active'] ?? mapData['isActive'];

    return UserModel(
      userId: userId,
      avatar: avatar,
      username: username,
      token: token,
      email: email,
      loginType: loginType,
      fullName: fullName,
      phone: phone,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    // giữ key cũ để không phá code đang dùng (local storage, v.v)
    'userId': userId,
    'avatar': avatar,
    'username': username,
    'token': token,
    'email': email,
    'loginType': loginType,
    // thêm key dạng backend (nếu gửi ngược server)
    'user_id': userId,
    'full_name': fullName,
    'phone': phone,
    'role': role?.backendName,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'is_active': isActive,
  };

  UserModel copyWith({
    int? userId,
    String? avatar,
    String? username,
    String? token,
    String? email,
    String? loginType,
    String? fullName,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      token: token ?? this.token,
      email: email ?? this.email,
      loginType: loginType ?? this.loginType,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [userId, username, email, role, isActive];

  @override
  String toString() {
    return 'User(userId: $userId, username: $username, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }
}
