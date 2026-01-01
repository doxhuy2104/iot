import 'package:app/core/constants/app_environment.dart';
import 'package:app/core/network/dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:app/core/utils/utils.dart';

class HomeApi {
  final Dio _dio;
  // receive timeout
  static const int receiveTimeout = 20;
  // connection timeout
  static const int connectionTimeout = 20;
  HomeApi(this._dio) {
    _dio
      ..options.baseUrl = 'http://api.weatherapi.com/v1'
      ..options.connectTimeout = const Duration(seconds: connectionTimeout)
      ..options.receiveTimeout = const Duration(seconds: receiveTimeout)
      ..options.responseType = ResponseType.json
      ..interceptors.addAll([DioInterceptor(dio: _dio)]);
  }
  Future<Response> getWeather() async {
    const String url = '/current.json';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'key': AppEnvironment.weatherApiKey,
          'q': '20.996807, 105.784422',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
