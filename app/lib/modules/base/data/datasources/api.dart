import 'package:dio/dio.dart';
import 'package:app/core/utils/utils.dart';

class Api {
  final dioClient = Utils.dioClient;
  Future<Response> base() async {
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
