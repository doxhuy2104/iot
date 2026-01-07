import 'package:equatable/equatable.dart';

class FlowDataModel extends Equatable {
  final int? id;
  final int? deviceId;
  final int? zoneId;
  final int? pulseCount;
  final double? flowRatePerMinute;
  final double? cumulativeLiters;
  final DateTime? createdAt;

  const FlowDataModel({
    this.id,
    this.deviceId,
    this.zoneId,
    this.pulseCount,
    this.flowRatePerMinute,
    this.cumulativeLiters,
    this.createdAt,
  });

  static FlowDataModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['flow_id'] ?? mapData['id'];
    final int? deviceId = mapData['device_id'] ?? mapData['deviceId'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final int? pulseCount = mapData['pulse_count'] ?? mapData['pulseCount'];
    final double? flowRatePerMinute =
        (mapData['flow_rate_per_minute'] ??
                mapData['flowRatePerMinute'] as num?)
            ?.toDouble();
    final double? cumulativeLiters =
        (mapData['cumulative_liters'] ?? mapData['cumulativeLiters'] as num?)
            ?.toDouble();
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;

    return FlowDataModel(
      id: id,
      deviceId: deviceId,
      zoneId: zoneId,
      pulseCount: pulseCount,
      flowRatePerMinute: flowRatePerMinute,
      cumulativeLiters: cumulativeLiters,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'flow_id': id,
    'device_id': deviceId,
    'zone_id': zoneId,
    'pulse_count': pulseCount,
    'flow_rate_per_minute': flowRatePerMinute,
    'cumulative_liters': cumulativeLiters,
    'created_at': createdAt?.toIso8601String(),
  };

  FlowDataModel copyWith({
    int? id,
    int? deviceId,
    int? zoneId,
    int? pulseCount,
    double? flowRatePerMinute,
    double? cumulativeLiters,
    DateTime? createdAt,
  }) {
    return FlowDataModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      zoneId: zoneId ?? this.zoneId,
      pulseCount: pulseCount ?? this.pulseCount,
      flowRatePerMinute: flowRatePerMinute ?? this.flowRatePerMinute,
      cumulativeLiters: cumulativeLiters ?? this.cumulativeLiters,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    zoneId,
    pulseCount,
    flowRatePerMinute,
    cumulativeLiters,
    createdAt,
  ];

  @override
  String toString() {
    return 'FlowData(id: $id, deviceId: $deviceId, zoneId: $zoneId, pulseCount: $pulseCount, flowRatePerMinute: $flowRatePerMinute, cumulativeLiters: $cumulativeLiters, createdAt: $createdAt)';
  }
}
