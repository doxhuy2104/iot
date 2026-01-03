import 'package:equatable/equatable.dart';

class ZoneModel extends Equatable {
  final int? zoneId;
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
  final String? deviceIdentifier;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ZoneModel({
    this.zoneId,
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
    this.deviceIdentifier,
    this.createdAt,
    this.updatedAt,
  });

  static ZoneModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? zoneId = mapData['zoneId'] ?? mapData['id'];
    final int? userId = mapData['userId'];
    final String? zoneName = mapData['zoneName'];
    final String? location = mapData['location']?.toString();
    final String? description = mapData['description'];
    final String? longitude = (mapData['longitude'] ?? mapData['longtitude'])
        ?.toString();
    final String? latitude = mapData['latitude']?.toString();
    final double? thresholdValue = (mapData['thresholdValue'] as num?)
        ?.toDouble();
    final bool? autoMode = mapData['autoMode'];
    final bool? weatherMode = mapData['weatherMode'];
    final bool? pumpStatus = mapData['pumpStatus'];
    final String? deviceIdentifier = mapData['deviceIdentifier'];
    final DateTime? createdAt = mapData['createdAt'] != null
        ? (mapData['createdAt'] is DateTime
              ? mapData['createdAt']
              : DateTime.tryParse(mapData['createdAt'].toString()))
        : null;
    final DateTime? updatedAt = mapData['updatedAt'] != null
        ? (mapData['updatedAt'] is DateTime
              ? mapData['updatedAt']
              : DateTime.tryParse(mapData['updatedAt'].toString()))
        : null;

    return ZoneModel(
      zoneId: zoneId,
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
      deviceIdentifier: deviceIdentifier,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'zoneId': zoneId,
    'userId': userId,
    'zoneName': zoneName,
    'location': location,
    'description': description,
    'longitude': longitude,
    'latitude': latitude,
    'thresholdValue': thresholdValue,
    'autoMode': autoMode,
    'weatherMode': weatherMode,
    'pumpStatus': pumpStatus,
    'deviceIdentifier': deviceIdentifier,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  ZoneModel copyWith({
    int? zoneId,
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
    String? deviceIdentifier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ZoneModel(
      zoneId: zoneId ?? this.zoneId,
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
      deviceIdentifier: deviceIdentifier ?? this.deviceIdentifier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    zoneId,
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
    deviceIdentifier,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Zone(zoneId: $zoneId, userId: $userId, zoneName: $zoneName, location: $location, description: $description, longitude: $longitude, latitude: $latitude, thresholdValue: $thresholdValue, autoMode: $autoMode, weatherMode: $weatherMode, pumpStatus: $pumpStatus, deviceIdentifier: $deviceIdentifier, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
