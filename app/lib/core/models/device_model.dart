import 'package:equatable/equatable.dart';

/// Map với enum `Device.DeviceType` trong backend
/// (SOIL_MOISTURE_SENSOR, FLOW_SENSOR, PUMP, VALVE, ESP32_CONTROLLER)
enum DeviceType {
  soilMoistureSensor,
  flowSensor,
  pump,
  valve,
  esp32Controller;

  static DeviceType? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().replaceAll('_', '');
    try {
      return DeviceType.values.firstWhere(
        (e) => e.name.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  String get backendName {
    switch (this) {
      case DeviceType.soilMoistureSensor:
        return 'SOIL_MOISTURE_SENSOR';
      case DeviceType.flowSensor:
        return 'FLOW_SENSOR';
      case DeviceType.pump:
        return 'PUMP';
      case DeviceType.valve:
        return 'VALVE';
      case DeviceType.esp32Controller:
        return 'ESP32_CONTROLLER';
    }
  }
}

/// Map với enum `Device.DeviceStatus` trong backend
/// (ONLINE, OFFLINE, ERROR, MAINTENANCE)
enum DeviceStatus {
  online,
  offline,
  error,
  maintenance;

  static DeviceStatus? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase();
    try {
      return DeviceStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  String get backendName {
    switch (this) {
      case DeviceStatus.online:
        return 'ONLINE';
      case DeviceStatus.offline:
        return 'OFFLINE';
      case DeviceStatus.error:
        return 'ERROR';
      case DeviceStatus.maintenance:
        return 'MAINTENANCE';
    }
  }
}

class DeviceModel extends Equatable {
  final int? id;
  final int? zoneId;
  final String? deviceName;
  final DeviceType? type;
  final String? identifier;
  final String? mqttTopicPublish;
  final String? mqttTopicSubscribe;
  final DeviceStatus? status;
  final DateTime? createdAt;

  const DeviceModel({
    this.id,
    this.zoneId,
    this.deviceName,
    this.type,
    this.identifier,
    this.mqttTopicPublish,
    this.mqttTopicSubscribe,
    this.status,
    this.createdAt,
  });

  static DeviceModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['device_id'] ?? mapData['id'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final String? deviceName = mapData['device_name'] ?? mapData['deviceName'];
    final DeviceType? type = DeviceType.fromString(
      mapData['type'] ?? mapData['device_type'],
    );
    final String? identifier = mapData['identifier'];
    final String? mqttTopicPublish =
        mapData['mqtt_topic_publish'] ?? mapData['mqttTopicPublish'];
    final String? mqttTopicSubscribe =
        mapData['mqtt_topic_subscribe'] ?? mapData['mqttTopicSubscribe'];
    final DeviceStatus? status = DeviceStatus.fromString(mapData['status']);
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;

    return DeviceModel(
      id: id,
      zoneId: zoneId,
      deviceName: deviceName,
      type: type,
      identifier: identifier,
      mqttTopicPublish: mqttTopicPublish,
      mqttTopicSubscribe: mqttTopicSubscribe,
      status: status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'device_id': id,
    'zone_id': zoneId,
    'device_name': deviceName,
    'type': type?.backendName,
    'identifier': identifier,
    'mqtt_topic_publish': mqttTopicPublish,
    'mqtt_topic_subscribe': mqttTopicSubscribe,
    'status': status?.backendName,
    'created_at': createdAt?.toIso8601String(),
  };

  DeviceModel copyWith({
    int? id,
    int? zoneId,
    String? deviceName,
    DeviceType? type,
    String? identifier,
    String? mqttTopicPublish,
    String? mqttTopicSubscribe,
    DeviceStatus? status,
    DateTime? createdAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      deviceName: deviceName ?? this.deviceName,
      type: type ?? this.type,
      identifier: identifier ?? this.identifier,
      mqttTopicPublish: mqttTopicPublish ?? this.mqttTopicPublish,
      mqttTopicSubscribe: mqttTopicSubscribe ?? this.mqttTopicSubscribe,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    deviceName,
    type,
    identifier,
    mqttTopicPublish,
    mqttTopicSubscribe,
    status,
    createdAt,
  ];

  @override
  String toString() {
    return 'Device(id: $id, zoneId: $zoneId, deviceName: $deviceName, type: $type, identifier: $identifier, mqttTopicPublish: $mqttTopicPublish, mqttTopicSubscribe: $mqttTopicSubscribe, status: $status, createdAt: $createdAt)';
  }
}
