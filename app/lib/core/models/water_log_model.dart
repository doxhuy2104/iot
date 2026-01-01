import 'package:equatable/equatable.dart';

enum WaterLogReason {
  manual,
  autoMoisture,
  scheduled,
  weatherBased;

  static WaterLogReason? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toUpperCase();
    try {
      switch (normalized) {
        case 'MANUAL':
          return WaterLogReason.manual;
        case 'AUTO_MOISTURE':
          return WaterLogReason.autoMoisture;
        case 'SCHEDULED':
          return WaterLogReason.scheduled;
        case 'WEATHER_BASED':
          return WaterLogReason.weatherBased;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String get backendName {
    switch (this) {
      case WaterLogReason.manual:
        return 'MANUAL';
      case WaterLogReason.autoMoisture:
        return 'AUTO_MOISTURE';
      case WaterLogReason.scheduled:
        return 'SCHEDULED';
      case WaterLogReason.weatherBased:
        return 'WEATHER_BASED';
    }
  }
}

enum WaterLogStatus {
  pending,
  completed,
  notYet,
  interrupted;

  static WaterLogStatus? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().replaceAll(' ', '');
    try {
      return WaterLogStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == normalized ||
            (normalized == 'notyet' && e == WaterLogStatus.notYet),
      );
    } catch (_) {
      return null;
    }
  }

  String get backendName {
    switch (this) {
      case WaterLogStatus.pending:
        return 'PENDING';
      case WaterLogStatus.completed:
        return 'COMPLETED';
      case WaterLogStatus.notYet:
        return 'NOT_YET';
      case WaterLogStatus.interrupted:
        return 'INTERRUPTED';
    }
  }
}

class WaterLogModel extends Equatable {
  final int? id;
  final int? zoneId;
  final int? deviceId;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final double? waterVolumeLiters;
  final WaterLogReason? reason;
  final WaterLogStatus? status;
  final DateTime? createdAt;

  const WaterLogModel({
    this.id,
    this.zoneId,
    this.deviceId,
    this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.waterVolumeLiters,
    this.reason,
    this.status,
    this.createdAt,
  });

  static WaterLogModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['log_id'] ?? mapData['id'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final int? deviceId = mapData['device_id'] ?? mapData['deviceId'];
    final DateTime? startedAt = mapData['started_at'] != null
        ? (mapData['started_at'] is DateTime
              ? mapData['started_at']
              : DateTime.tryParse(mapData['started_at'].toString()))
        : null;
    final DateTime? endedAt = mapData['ended_at'] != null
        ? (mapData['ended_at'] is DateTime
              ? mapData['ended_at']
              : DateTime.tryParse(mapData['ended_at'].toString()))
        : null;
    final int? durationSeconds =
        mapData['duration_seconds'] ??
        mapData['duration_sec'] ??
        mapData['durationSeconds'];
    final double? waterVolumeLiters =
        (mapData['water_volume_liters'] ??
                mapData['water_volume_l'] ??
                mapData['waterVolumeLiters'] as num?)
            ?.toDouble();
    final WaterLogReason? reason = WaterLogReason.fromString(mapData['reason']);
    final WaterLogStatus? status = WaterLogStatus.fromString(
      mapData['status'] ?? mapData['water_status'],
    );
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;

    return WaterLogModel(
      id: id,
      zoneId: zoneId,
      deviceId: deviceId,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSeconds: durationSeconds,
      waterVolumeLiters: waterVolumeLiters,
      reason: reason,
      status: status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'log_id': id,
    'zone_id': zoneId,
    'device_id': deviceId,
    'started_at': startedAt?.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'duration_seconds': durationSeconds,
    'water_volume_liters': waterVolumeLiters,
    'reason': reason?.backendName,
    'status': status?.backendName,
    'created_at': createdAt?.toIso8601String(),
  };

  WaterLogModel copyWith({
    int? id,
    int? zoneId,
    int? deviceId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    double? waterVolumeLiters,
    WaterLogReason? reason,
    WaterLogStatus? status,
    DateTime? createdAt,
  }) {
    return WaterLogModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      deviceId: deviceId ?? this.deviceId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      waterVolumeLiters: waterVolumeLiters ?? this.waterVolumeLiters,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    deviceId,
    startedAt,
    endedAt,
    durationSeconds,
    waterVolumeLiters,
    reason,
    status,
    createdAt,
  ];

  @override
  String toString() {
    return 'WaterLog(id: $id, zoneId: $zoneId, deviceId: $deviceId, startedAt: $startedAt, endedAt: $endedAt, durationSeconds: $durationSeconds, waterVolumeLiters: $waterVolumeLiters, reason: $reason, status: $status, createdAt: $createdAt)';
  }
}
