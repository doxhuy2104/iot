import 'package:app/modules/home/data/datasources/home_api.dart';
import 'package:app/modules/home/data/models/location_model.dart';
import 'package:app/modules/home/data/models/weather_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:app/core/network/dio_exceptions.dart';
import 'package:app/core/network/dio_failure.dart';

class HomeRepository {
  final HomeApi api;

  HomeRepository({required this.api});

  Future<Either<DioFailure, Map<String, dynamic>>> getWeather() async {
    try {
      final response = await api.getWeather();
      final LocationModel? location = LocationModel.fromJson(
        response.data['location'],
      );
      final WeatherModel? weather = WeatherModel.fromJson(
        response.data['current'],
      );

      return Right({'location': location, 'weather': weather});
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }
}
