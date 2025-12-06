import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app/core/network/dio_exceptions.dart';
import 'package:app/core/network/dio_failure.dart';
import 'package:app/modules/auth/data/datasources/auth_api.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository({required this.api});

  Future<Either<DioFailure, Map<String, dynamic>>> login({
    required String username,
  }) async {
    try {
      final response = await api.login(username);
      final Map<String, dynamic> data = response.data['account'];
      return Right(data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }
}
