import 'package:equatable/equatable.dart';

abstract class DioFailure extends Equatable {
  final String reason;
  final String statusCode;
  final String code;

  const DioFailure(
      {required this.reason, required this.statusCode, this.code = ''});

  @override
  List<Object?> get props => [reason, statusCode, code];
}

class ApiFailure extends DioFailure {
  const ApiFailure(
      {required super.reason, required super.statusCode, super.code});
}
