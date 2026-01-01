import 'package:equatable/equatable.dart';

/// Map với enum `UserAction.ActionType` trong backend
enum UserActionType {
  manualWaterOn,
  manualWaterOff,
  scheduleCreate,
  scheduleUpdate,
  scheduleDelete,
  zoneCreate,
  zoneUpdate,
  zoneDelete,
  configUpdate,
  deviceAdd,
  deviceRemove;

  static UserActionType? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().replaceAll('_', '');
    try {
      return UserActionType.values.firstWhere(
        (e) => e.name.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  String get backendName {
    switch (this) {
      case UserActionType.manualWaterOn:
        return 'MANUAL_WATER_ON';
      case UserActionType.manualWaterOff:
        return 'MANUAL_WATER_OFF';
      case UserActionType.scheduleCreate:
        return 'SCHEDULE_CREATE';
      case UserActionType.scheduleUpdate:
        return 'SCHEDULE_UPDATE';
      case UserActionType.scheduleDelete:
        return 'SCHEDULE_DELETE';
      case UserActionType.zoneCreate:
        return 'ZONE_CREATE';
      case UserActionType.zoneUpdate:
        return 'ZONE_UPDATE';
      case UserActionType.zoneDelete:
        return 'ZONE_DELETE';
      case UserActionType.configUpdate:
        return 'CONFIG_UPDATE';
      case UserActionType.deviceAdd:
        return 'DEVICE_ADD';
      case UserActionType.deviceRemove:
        return 'DEVICE_REMOVE';
    }
  }
}

class UserActionModel extends Equatable {
  final int? id;
  final int? userId;
  final int? zoneId;
  final int? deviceId;
  final UserActionType? actionType;
  final String? details;
  final DateTime? createdAt;

  const UserActionModel({
    this.id,
    this.userId,
    this.zoneId,
    this.deviceId,
    this.actionType,
    this.details,
    this.createdAt,
  });

  static UserActionModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['action_id'] ?? mapData['id'];
    final int? userId = mapData['user_id'] ?? mapData['userId'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final int? deviceId = mapData['device_id'] ?? mapData['deviceId'];
    final UserActionType? actionType = UserActionType.fromString(
      mapData['action_type'] ?? mapData['actionType'],
    );
    final String? details = mapData['details'];
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;

    return UserActionModel(
      id: id,
      userId: userId,
      zoneId: zoneId,
      deviceId: deviceId,
      actionType: actionType,
      details: details,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'action_id': id,
    'user_id': userId,
    'zone_id': zoneId,
    'device_id': deviceId,
    'action_type': actionType?.backendName,
    'details': details,
    'created_at': createdAt?.toIso8601String(),
  };

  UserActionModel copyWith({
    int? id,
    int? userId,
    int? zoneId,
    int? deviceId,
    UserActionType? actionType,
    String? details,
    DateTime? createdAt,
  }) {
    return UserActionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      zoneId: zoneId ?? this.zoneId,
      deviceId: deviceId ?? this.deviceId,
      actionType: actionType ?? this.actionType,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    zoneId,
    deviceId,
    actionType,
    details,
    createdAt,
  ];

  @override
  String toString() {
    return 'UserAction(id: $id, userId: $userId, zoneId: $zoneId, deviceId: $deviceId, actionType: $actionType, details: $details, createdAt: $createdAt)';
  }
}
