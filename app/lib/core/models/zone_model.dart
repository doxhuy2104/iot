import 'package:equatable/equatable.dart';

class ZoneModel extends Equatable {
  final int? id;
  final int? userId;
  final String? zoneName;
  final String? location;
  final String? description;
  final String? longitude;
  final String? latitude;
  final double? thresholdValue;
  final bool? autoMode;
  final bool? weatherMode;
  final bool? pumpStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ZoneModel({
    this.id,
    this.userId,
    this.zoneName,
    this.location,
    this.description,
    this.longitude,
    this.latitude,
    this.thresholdValue,
    this.autoMode,
    this.weatherMode,
    this.pumpStatus,
    this.createdAt,
    this.updatedAt,
  });

  static ZoneModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['zone_id'] ?? mapData['id'];
    final int? userId = mapData['user_id'] ?? mapData['userId'];
    final String? zoneName = mapData['zone_name'] ?? mapData['zoneName'];
    final String? location = mapData['location']
        ?.toString(); // backend BigDecimal -> String
    final String? description = mapData['description'];
    final String? longitude =
        mapData['longitude'] ?? mapData['longtitude']; // phòng trường hợp typo
    final String? latitude = mapData['latitude']?.toString();
    final double? thresholdValue =
        (mapData['threshold_value'] ?? mapData['thresholdValue'] as num?)
            ?.toDouble();
    final bool? autoMode = mapData['auto_mode'] ?? mapData['autoMode'];
    final bool? weatherMode = mapData['weather_mode'] ?? mapData['weatherMode'];
    final bool? pumpStatus = mapData['pump_status'] ?? mapData['pumpStatus'];
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

    return ZoneModel(
      id: id,
      userId: userId,
      zoneName: zoneName,
      location: location,
      description: description,
      longitude: longitude,
      latitude: latitude,
      thresholdValue: thresholdValue,
      autoMode: autoMode,
      weatherMode: weatherMode,
      pumpStatus: pumpStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'zone_id': id,
    'user_id': userId,
    'zone_name': zoneName,
    'location': location,
    'description': description,
    'longitude': longitude,
    'latitude': latitude,
    'threshold_value': thresholdValue,
    'auto_mode': autoMode,
    'weather_mode': weatherMode,
    'pump_status': pumpStatus,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  ZoneModel copyWith({
    int? id,
    int? userId,
    String? zoneName,
    String? location,
    String? description,
    String? longitude,
    String? latitude,
    double? thresholdValue,
    bool? autoMode,
    bool? weatherMode,
    bool? pumpStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZoneModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      zoneName: zoneName ?? this.zoneName,
      location: location ?? this.location,
      description: description ?? this.description,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      thresholdValue: thresholdValue ?? this.thresholdValue,
      autoMode: autoMode ?? this.autoMode,
      weatherMode: weatherMode ?? this.weatherMode,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    zoneName,
    location,
    description,
    longitude,
    latitude,
    thresholdValue,
    autoMode,
    weatherMode,
    pumpStatus,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Zone(id: $id, userId: $userId, zoneName: $zoneName, location: $location, description: $description, longitude: $longitude, latitude: $latitude, thresholdValue: $thresholdValue, autoMode: $autoMode, weatherMode: $weatherMode, pumpStatus: $pumpStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
