import 'package:app/core/utils/utils.dart';
import 'package:dio/dio.dart';

class ZoneApi {
  final dioClient = Utils.dioClient;
  Future<Response> getZones() async {
    const String url = '';
    try {
      final response = await dioClient.get(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendWifi(String ssid, String password) async {
    const String url = 'http://192.168.4.1/wifi';
    try {
      final response = await dioClient.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'ssid': ssid, 'password': password},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
