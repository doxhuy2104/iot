import 'package:app/core/constants/app_configs.dart';
import 'package:app/core/helpers/general_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  AppEnvironment._();

  static String get envFileName => '.env';

  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  // static String get websocketUrl => dotenv.env['WEBSOCKET_URL'] ?? '';
  static String get firebaseWebClientId =>
      dotenv.env['FIREBASE_WEB_CLIENT_ID'] ?? '';

      static String get weatherApiKey =>
      dotenv.env['WEATHER_API_KEY'] ?? '';
}
