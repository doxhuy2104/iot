import 'package:app/core/constants/app_environment.dart';
import 'package:app/core/utils/globals.dart';
import 'package:app/core/utils/utils.dart';
import 'package:dio/dio.dart';

class HomeApi {
  final dio = Utils.dioClient;
  Future<Response> getWeather() async {
    const String url = 'http://api.weatherapi.com/v1/current.json';
    try {
      final location = Globals.globalLocation;
      // Default location if globalLocation is null
      String q = '20.996807, 105.784422';
      if (location != null) {
        q = '${location.latitude},${location.longitude}';
      }

      final response = await dio.get(
        url,
        queryParameters: {'key': AppEnvironment.weatherApiKey, 'q': q},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
