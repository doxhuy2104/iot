import 'package:equatable/equatable.dart';

/// Map với enum `Alert.AlertSeverity` trong backend
/// (INFO, WARNING, ERROR, CRITICAL)
enum AlertSeverity {
  info,
  warning,
  error,
  critical;

  static AlertSeverity? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    try {
      return AlertSeverity.values.firstWhere(
        (e) => e.name.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }
}

class AlertModel extends Equatable {
  final int? id;
  final int? zoneId;
  final int? deviceId;
  final AlertSeverity? severity;
  final String? message;
  final bool? isHandled;
  final DateTime? handledAt;
  final DateTime? createdAt;
  final String? mqttPayload;
  final DateTime? mqttReceivedAt;
  final int? handledByUserId;

  const AlertModel({
    this.id,
    this.zoneId,
    this.deviceId,
    this.severity,
    this.message,
    this.isHandled,
    this.handledAt,
    this.createdAt,
    this.mqttPayload,
    this.mqttReceivedAt,
    this.handledByUserId,
  });

  static AlertModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['alert_id'] ?? mapData['id'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final int? deviceId = mapData['device_id'] ?? mapData['deviceId'];
    final AlertSeverity? severity = AlertSeverity.fromString(
      mapData['severity'],
    );
    final String? message = mapData['message'];
    final bool? isHandled =
        mapData['is_handled'] ?? mapData['handled'] ?? mapData['isHandled'];
    final DateTime? handledAt = mapData['handled_at'] != null
        ? (mapData['handled_at'] is DateTime
              ? mapData['handled_at']
              : DateTime.tryParse(mapData['handled_at'].toString()))
        : null;
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;
    final String? mqttPayload =
        mapData['mqtt_payload'] ?? mapData['mqttPayload'];
    final DateTime? mqttReceivedAt = mapData['mqtt_received_at'] != null
        ? (mapData['mqtt_received_at'] is DateTime
              ? mapData['mqtt_received_at']
              : DateTime.tryParse(mapData['mqtt_received_at'].toString()))
        : null;
    final int? handledByUserId =
        mapData['handled_by'] ?? mapData['handledByUserId'];

    return AlertModel(
      id: id,
      zoneId: zoneId,
      deviceId: deviceId,
      severity: severity,
      message: message,
      isHandled: isHandled,
      handledAt: handledAt,
      createdAt: createdAt,
      mqttPayload: mqttPayload,
      mqttReceivedAt: mqttReceivedAt,
      handledByUserId: handledByUserId,
    );
  }

  Map<String, dynamic> toJson() => {
    'alert_id': id,
    'zone_id': zoneId,
    'device_id': deviceId,
    'severity': severity?.name.toUpperCase(),
    'message': message,
    'is_handled': isHandled,
    'handled_at': handledAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'mqtt_payload': mqttPayload,
    'mqtt_received_at': mqttReceivedAt?.toIso8601String(),
    'handled_by': handledByUserId,
  };

  AlertModel copyWith({
    int? id,
    int? zoneId,
    int? deviceId,
    AlertSeverity? severity,
    String? message,
    bool? isHandled,
    DateTime? handledAt,
    DateTime? createdAt,
    String? mqttPayload,
    DateTime? mqttReceivedAt,
    int? handledByUserId,
  }) {
    return AlertModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      deviceId: deviceId ?? this.deviceId,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      isHandled: isHandled ?? this.isHandled,
      handledAt: handledAt ?? this.handledAt,
      createdAt: createdAt ?? this.createdAt,
      mqttPayload: mqttPayload ?? this.mqttPayload,
      mqttReceivedAt: mqttReceivedAt ?? this.mqttReceivedAt,
      handledByUserId: handledByUserId ?? this.handledByUserId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    deviceId,
    severity,
    message,
    isHandled,
    handledAt,
    createdAt,
    mqttPayload,
    mqttReceivedAt,
    handledByUserId,
  ];

  @override
  String toString() {
    return 'Alert(id: $id, zoneId: $zoneId, deviceId: $deviceId, severity: $severity, message: $message, isHandled: $isHandled, handledAt: $handledAt, createdAt: $createdAt, mqttPayload: $mqttPayload, mqttReceivedAt: $mqttReceivedAt, handledByUserId: $handledByUserId)';
  }
}
