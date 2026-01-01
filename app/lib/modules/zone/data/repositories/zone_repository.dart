import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app/core/network/dio_exceptions.dart';
import 'package:app/core/network/dio_failure.dart';
import 'package:app/modules/zone/data/datasources/zone_api.dart';

class ZoneRepository {
  final ZoneApi api;

  ZoneRepository({required this.api});

  Future<Either<DioFailure, void>> getZones() async {
    try {
      final response = await api.getZones();
      return Right(null);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }
}
