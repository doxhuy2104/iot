import 'package:equatable/equatable.dart';

final class ZoneState extends Equatable {
  const ZoneState._();

  @override
  List<Object?> get props => [];

  const ZoneState.initial() : this._();
  ZoneState reset() {
    return ZoneState._();
  }

  ZoneState setState() {
    return ZoneState._();
  }

  ZoneState.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => {};
}
