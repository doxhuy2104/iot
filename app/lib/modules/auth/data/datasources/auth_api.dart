import 'package:dio/dio.dart';
import 'package:app/core/utils/utils.dart';

class AuthApi {
  final dioClient = Utils.dioClient;
  Future<Response> login(String username) async {
    const String url = '/api/v1/get-user';
    try {
      final response = await dioClient.get(
        url,
        queryParameters: {'username': username},
        options: Options(extra: {'notShowError': true}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
