import 'package:equatable/equatable.dart';

class ConditionModel extends Equatable {
  final String? text;
  final String? icon;

  const ConditionModel({this.text, this.icon});

  static ConditionModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final String? text = mapData['text'];
    final String? icon = mapData['icon'];

    return ConditionModel(text: text, icon: icon);
  }

  Map<String, dynamic> toJson() => {'text': text, 'icon': icon};

  ConditionModel copyWith({String? text, String? icon}) {
    return ConditionModel(text: text ?? this.text, icon: icon ?? this.icon);
  }

  @override
  List<Object?> get props => [text, icon];
}

class WeatherModel extends Equatable {
  final double? tempC;
  final int? isDay;
  final ConditionModel? condition;
  final double? windMph;
  final double? windKph;
  final int? windDegree;
  final double? precipMm;
  final int? humidity;
  final int? cloud;
  final double? feelslikeC;
  final double? uv;

  const WeatherModel({
    this.tempC,
    this.isDay,
    this.condition,
    this.windMph,
    this.windKph,
    this.windDegree,
    this.precipMm,
    this.humidity,
    this.cloud,
    this.feelslikeC,
    this.uv,
  });

  static WeatherModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final double? tempC = (mapData['temp_c'] as num?)?.toDouble();
    final int? isDay = mapData['is_day'];
    final ConditionModel? condition = ConditionModel.fromJson(
      mapData['condition'],
    );
    final double? windMph = (mapData['wind_mph'] as num?)?.toDouble();
    final double? windKph = (mapData['wind_kph'] as num?)?.toDouble();
    final int? windDegree = mapData['wind_degree'];
    final double? precipMm = (mapData['precip_mm'] as num?)?.toDouble();
    final int? humidity = mapData['humidity'];
    final int? cloud = mapData['cloud'];
    final double? feelslikeC = (mapData['feelslike_c'] as num?)?.toDouble();
    final double? uv = (mapData['uv'] as num?)?.toDouble();

    return WeatherModel(
      tempC: tempC,
      isDay: isDay,
      condition: condition,
      windMph: windMph,
      windKph: windKph,
      windDegree: windDegree,
      precipMm: precipMm,
      humidity: humidity,
      cloud: cloud,
      feelslikeC: feelslikeC,
      uv: uv,
    );
  }

  Map<String, dynamic> toJson() => {
    'temp_c': tempC,
    'is_day': isDay,
    'condition': condition?.toJson(),
    'wind_mph': windMph,
    'wind_kph': windKph,
    'wind_degree': windDegree,
    'precip_mm': precipMm,
    'humidity': humidity,
    'cloud': cloud,
    'feelslike_c': feelslikeC,
    'uv': uv,
  };

  WeatherModel copyWith({
    double? tempC,
    int? isDay,
    ConditionModel? condition,
    double? windMph,
    double? windKph,
    int? windDegree,
    double? precipMm,
    int? humidity,
    int? cloud,
    double? feelslikeC,
    double? uv,
  }) {
    return WeatherModel(
      tempC: tempC ?? this.tempC,
      isDay: isDay ?? this.isDay,
      condition: condition ?? this.condition,
      windMph: windMph ?? this.windMph,
      windKph: windKph ?? this.windKph,
      windDegree: windDegree ?? this.windDegree,
      precipMm: precipMm ?? this.precipMm,
      humidity: humidity ?? this.humidity,
      cloud: cloud ?? this.cloud,
      feelslikeC: feelslikeC ?? this.feelslikeC,
      uv: uv ?? this.uv,
    );
  }

  @override
  List<Object?> get props => [
    tempC,
    isDay,
    condition,
    windMph,
    windKph,
    windDegree,
    precipMm,
    humidity,
    cloud,
    feelslikeC,
    uv,
  ];

  @override
  String toString() {
    return 'Weather(tempC: $tempC, isDay: $isDay, condition: $condition, windMph: $windMph, windKph: $windKph, windDegree: $windDegree, precipMm: $precipMm, humidity: $humidity, cloud: $cloud, feelslikeC: $feelslikeC, uv: $uv)';
  }
}
