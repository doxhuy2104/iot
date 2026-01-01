import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app/core/network/dio_exceptions.dart';
import 'package:app/core/network/dio_failure.dart';
import 'package:app/modules/account/data/datasources/account_api.dart';

class AccountRepository {
  final AccountApi api;

  AccountRepository({required this.api});

  Future<Either<DioFailure, void>> base() async {
    try {
      final response = await api.base();
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
