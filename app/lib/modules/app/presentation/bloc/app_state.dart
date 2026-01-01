import 'package:equatable/equatable.dart';

class AppState extends Equatable {
  const AppState._();

  @override
  List<Object?> get props => [];

  const AppState.initial() : this._();

  AppState setState() {
    return AppState._(

    );
  }

  AppState.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => {
  };

}
