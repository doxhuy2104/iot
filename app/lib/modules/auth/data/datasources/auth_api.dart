import 'package:dio/dio.dart';
import 'package:app/core/utils/utils.dart';

class AuthApi {
  final dioClient = Utils.dioClient;
  Future<Response> login(String username,String password) async {
    const String url = '/api/auth/login';
    try {
      final response = await dioClient.post(
        url,
        data: {'username': username,'password':password},
        options: Options(extra: {'notShowError': true}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> register(String username,String email, String password) async {
    const String url = '/api/auth/register';
    try {
      final response = await dioClient.post(
        url,
        data: {'username': username,'email': email,'password':password},
        options: Options(extra: {'notShowError': true,}),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
