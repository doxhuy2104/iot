import 'package:equatable/equatable.dart';

enum NotificationType {
  alert,
  info,
  system;

  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    try {
      return NotificationType.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

class NotificationModel extends Equatable {
  final int? id;
  final int? userId;
  final int? alertId;
  final NotificationType? type;
  final String? message;
  final String? title;
  final bool? isRead;
  final DateTime? createdAt;

  const NotificationModel({
    this.id,
    this.userId,
    this.alertId,
    this.type,
    this.message,
    this.title,
    this.isRead,
    this.createdAt,
  });

  static NotificationModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['noti_id'] ?? mapData['id'];
    final int? userId = mapData['user_id'] ?? mapData['userId'];
    final int? alertId = mapData['alert_id'] ?? mapData['alertId'];
    final NotificationType? type = NotificationType.fromString(mapData['type']);
    final String? message = mapData['message'];
    final String? title = mapData['title'];
    final bool? isRead = mapData['read'] ?? mapData['isRead'];
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;

    return NotificationModel(
      id: id,
      userId: userId,
      alertId: alertId,
      type: type,
      message: message,
      title: title,
      isRead: isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'noti_id': id,
    'user_id': userId,
    'alert_id': alertId,
    'type': type?.name,
    'message': message,
    'title': title,
    'read': isRead,
    'created_at': createdAt?.toIso8601String(),
  };

  NotificationModel copyWith({
    int? id,
    int? userId,
    int? alertId,
    NotificationType? type,
    String? message,
    String? title,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      alertId: alertId ?? this.alertId,
      type: type ?? this.type,
      message: message ?? this.message,
      title: title ?? this.title,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    alertId,
    type,
    message,
    title,
    isRead,
    createdAt,
  ];

  @override
  String toString() {
    return 'Notification(id: $id, userId: $userId, alertId: $alertId, type: $type, message: $message, title: $title, isRead: $isRead, createdAt: $createdAt)';
  }
}
