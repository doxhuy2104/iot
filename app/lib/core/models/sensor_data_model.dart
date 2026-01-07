import 'package:equatable/equatable.dart';

class SensorDataModel extends Equatable {
  final int? id;
  final int? zoneId;
  final int? deviceId;
  final double? soilMoisture;
  final double? temperature;
  final double? humidity;
  final DateTime? createdAt;

  const SensorDataModel({
    this.id,
    this.zoneId,
    this.deviceId,
    this.soilMoisture,
    this.temperature,
    this.humidity,
    this.createdAt,
  });

  static SensorDataModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['data_id'] ?? mapData['id'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final int? deviceId = mapData['device_id'] ?? mapData['deviceId'];
    final double? soilMoisture =
        (mapData['soil_moisture'] ?? mapData['soilMoisture'] as num?)
            ?.toDouble();
    // backend dùng cột "temparature" (bị typo) nên map cả hai key
    final double? temperature =
        (mapData['temparature'] ?? mapData['temperature'] as num?)?.toDouble();
    final double? humidity = (mapData['humidity'] ?? mapData['humid'] as num?)
        ?.toDouble();
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;

    return SensorDataModel(
      id: id,
      zoneId: zoneId,
      deviceId: deviceId,
      soilMoisture: soilMoisture,
      temperature: temperature,
      humidity: humidity,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'data_id': id,
    'zone_id': zoneId,
    'device_id': deviceId,
    'soil_moisture': soilMoisture,
    // ghi đúng key backend
    'temparature': temperature,
    'humidity': humidity,
    'created_at': createdAt?.toIso8601String(),
  };

  SensorDataModel copyWith({
    int? id,
    int? zoneId,
    int? deviceId,
    double? soilMoisture,
    double? temperature,
    double? humidity,
    DateTime? createdAt,
  }) {
    return SensorDataModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      deviceId: deviceId ?? this.deviceId,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    deviceId,
    soilMoisture,
    temperature,
    humidity,
    createdAt,
  ];

  @override
  String toString() {
    return 'SensorData(id: $id, zoneId: $zoneId, deviceId: $deviceId, soilMoisture: $soilMoisture, temperature: $temperature, humidity: $humidity, createdAt: $createdAt)';
  }
}
