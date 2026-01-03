import 'package:app/core/utils/utils.dart';
import 'package:dio/dio.dart';

class ZoneApi {
  final dioClient = Utils.dioClient;
  Future<Response> getZones() async {
    const String url = '/api/zones';
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

  Future<Response> createZone(Map<String, dynamic> data) async {
    const String url = '/api/zones';
    try {
      final response = await dioClient.post(url, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createDevice(Map<String, dynamic> data) async {
    const String url = '/api/devices';
    try {
      final response = await dioClient.post(url, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteZone(int id) async {
    final String url = '/api/zones/$id';
    try {
      final response = await dioClient.delete(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateZone(int id, Map<String, dynamic> data) async {
    final String url = '/api/zones/$id';
    try {
      final response = await dioClient.put(url, data: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getZoneDetail(int id) async {
    final String url = '/api/zones/$id';
    try {
      final response = await dioClient.get(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
