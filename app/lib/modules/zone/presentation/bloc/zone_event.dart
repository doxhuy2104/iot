import 'package:equatable/equatable.dart';

sealed class ZoneEvent extends Equatable {
  const ZoneEvent();

  @override
  List<Object?> get props => [];
}

class CreateZone extends ZoneEvent {
  final String zoneName;
  final String? location;
  final String? description;
  final String? longitude;
  final String? latitude;
  final double? thresholdValue;
  final bool? autoMode;
  final bool? weatherMode;

  const CreateZone({
    required this.zoneName,
    this.location,
    this.description,
    this.longitude,
    this.latitude,
    this.thresholdValue,
    this.autoMode,
    this.weatherMode,
  });
}

class GetZones extends ZoneEvent {}

class UpdateZoneEvent extends ZoneEvent {
  final int zoneId;
  final String? zoneName;
  final double? location;
  final String? description;
  final String? longitude;
  final double? latitude;
  final double? thresholdValue;
  final bool? autoMode;
  final bool? weatherMode;
  final bool? pumpStatus;

  const UpdateZoneEvent({
    required this.zoneId,
    this.zoneName,
    this.location,
    this.description,
    this.longitude,
    this.latitude,
    this.thresholdValue,
    this.autoMode,
    this.weatherMode,
    this.pumpStatus,
  });
}

class DeleteZoneEvent extends ZoneEvent {
  final int zoneId;

  const DeleteZoneEvent({required this.zoneId});
}

class GetZoneDetail extends ZoneEvent {
  final int zoneId;
  const GetZoneDetail({required this.zoneId});
}
