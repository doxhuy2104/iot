import 'package:dio/dio.dart';
import 'package:app/core/utils/utils.dart';

class ZoneApi {
  final dioClient = Utils.dioClient;
  Future<Response> getZones() async {
    const String url = '';
    try {
      final response = await dioClient.get(
        url,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
