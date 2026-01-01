import 'package:app/core/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app/core/network/dio_exceptions.dart';
import 'package:app/core/network/dio_failure.dart';
import 'package:app/modules/auth/data/datasources/auth_api.dart';

class AuthRepository {
  final AuthApi api;

  AuthRepository({required this.api});

  Future<Either<DioFailure, UserModel>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await api.login(username, password);
      final UserModel user =
          UserModel.fromJson(response.data['data'] as Map<String, dynamic>)
              as UserModel;
      return Right(user);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, void>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await api.register(username, email, password);
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
