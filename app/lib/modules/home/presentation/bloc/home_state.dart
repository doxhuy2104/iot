import 'package:app/modules/home/data/models/location_model.dart';
import 'package:app/modules/home/data/models/weather_model.dart';
import 'package:equatable/equatable.dart';

final class HomeState extends Equatable {
  final LocationModel? location;
  final WeatherModel? weather;

  const HomeState._({this.location, this.weather});

  @override
  List<Object?> get props => [location.hashCode, weather.hashCode];

  const HomeState.initial() : this._();

  HomeState reset() {
    return HomeState._();
  }

  HomeState setState({LocationModel? location, WeatherModel? weather}) {
    return HomeState._(
      location: location ?? this.location,
      weather: weather ?? this.weather,
    );
  }

  const HomeState.fromJson(Map<String, dynamic> json)
    : location = null,
      weather = null;

  Map<String, dynamic> toJson() => {};
}
