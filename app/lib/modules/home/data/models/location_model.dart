import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  final String? name;
  final String? region;
  final String? country;
  final double? lat;
  final double? lon;
  final String? tzId;
  final int? localtimeEpoch;
  final String? localtime;

  const LocationModel({
    this.name,
    this.region,
    this.country,
    this.lat,
    this.lon,
    this.tzId,
    this.localtimeEpoch,
    this.localtime,
  });

  static LocationModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final String? name = mapData['name'];
    final String? region = mapData['region'];
    final String? country = mapData['country'];
    final double? lat = (mapData['lat'] as num?)?.toDouble();
    final double? lon = (mapData['lon'] as num?)?.toDouble();
    final String? tzId = mapData['tz_id'];
    final int? localtimeEpoch = mapData['localtime_epoch'];
    final String? localtime = mapData['localtime'];

    return LocationModel(
      name: name,
      region: region,
      country: country,
      lat: lat,
      lon: lon,
      tzId: tzId,
      localtimeEpoch: localtimeEpoch,
      localtime: localtime,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'region': region,
    'country': country,
    'lat': lat,
    'lon': lon,
    'tz_id': tzId,
    'localtime_epoch': localtimeEpoch,
    'localtime': localtime,
  };

  LocationModel copyWith({
    String? name,
    String? region,
    String? country,
    double? lat,
    double? lon,
    String? tzId,
    int? localtimeEpoch,
    String? localtime,
  }) {
    return LocationModel(
      name: name ?? this.name,
      region: region ?? this.region,
      country: country ?? this.country,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      tzId: tzId ?? this.tzId,
      localtimeEpoch: localtimeEpoch ?? this.localtimeEpoch,
      localtime: localtime ?? this.localtime,
    );
  }

  @override
  List<Object?> get props => [
    name,
    region,
    country,
    lat,
    lon,
    tzId,
    localtimeEpoch,
    localtime,
  ];

  @override
  String toString() {
    return 'Location(name: $name, region: $region, country: $country, lat: $lat, lon: $lon, tzId: $tzId, localtimeEpoch: $localtimeEpoch, localtime: $localtime)';
  }
}
