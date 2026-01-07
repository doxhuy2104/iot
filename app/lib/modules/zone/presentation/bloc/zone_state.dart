import 'package:app/core/models/zone_model.dart';
import 'package:equatable/equatable.dart';

final class ZoneState extends Equatable {
  final List<ZoneModel> zones;

  const ZoneState._({this.zones = const []});

  @override
  List<Object?> get props => [zones];

  const ZoneState.initial() : this._();
  ZoneState reset() {
    return ZoneState._();
  }

  ZoneState setState({List<ZoneModel>? zones}) {
    return ZoneState._(zones: zones ?? this.zones);
  }

  ZoneState.fromJson(Map<String, dynamic> json) : zones = [];

  Map<String, dynamic> toJson() => {};
}
