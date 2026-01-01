import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/core/constants/app_keys.dart';
import 'package:app/core/helpers/general_helper.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/utils/globals.dart';
import 'package:app/core/utils/utils.dart';

class DioInterceptor extends Interceptor {
  final _sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();
  final Dio dio;

  DioInterceptor({required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // options.headers['Device-Id'] = GeneralHelper.deviceId;
    // options.headers['App-Version'] = GeneralHelper.appVersion;
    // options.headers['OS-Info'] = GeneralHelper.osInfo;
    // options.headers['Device-Info'] = GeneralHelper.deviceInfo;
    // options.headers['OS-Version'] = GeneralHelper.osVersion;

    options.headers['Accept-Language'] = GeneralHelper.deviceLanguageCode;
    options.headers['device-uuid'] = Globals.globalUuid;
    options.headers['device-name'] = GeneralHelper.deviceModel;
    options.headers['app-version'] = GeneralHelper.appVersion;
    options.headers['build-number'] = GeneralHelper.buildNumber;
    options.headers['os'] = GeneralHelper.osInfo.toUpperCase();
    options.headers['device-type'] = GeneralHelper.osInfo.toUpperCase();
    options.headers['os-version'] = GeneralHelper.osVersion;
    options.headers['mode'] = 'mobile';
    options.headers['accept-encoding'] =
        options.headers['accept-encoding'] ?? 'gzip';
    options.headers['content-type'] =
        options.headers['content-type'] ?? 'application/json';

    if (options.extra['noAuth'] != true) {
      if (Globals.globalAccessToken != null) {
        options.headers['Authorization'] = '${Globals.globalAccessToken}';
      }
    }

    options.headers['notification-token'] = Globals.globalFcmToken;
    options.headers['flavor'] = GeneralHelper.appFlavor;

    if (options.extra['noAuth'] != true) {
      if (Globals.globalUserId != null) {
        options.headers['userid'] = Globals.globalUserId;
      }
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final fullUrl = response.requestOptions.uri.toString();
    Utils.debugLogSuccess(
      '${response.requestOptions.method} $fullUrl (baseUrl: ${response.requestOptions.baseUrl}, path: ${response.requestOptions.path}) body:${response.requestOptions.data} query:${response.requestOptions.queryParameters}',
    );
    // emit to logs
    try {
      if (response.requestOptions.headers['content-type']
              ?.toString()
              .toLowerCase()
              .contains('multipart/form-data') ==
          true) {
        final formData = response.requestOptions.data as FormData;
        final map = {
          for (var field in formData.fields) field.key: field.value,
          for (var file in formData.files)
            file.key: file.value.filename, // only filename
        };
        final jsonString = jsonEncode(map);

        // LogService.log(
        //   LogTag.api,
        //   title:
        //       '${response.requestOptions.method} ${response.requestOptions.path} ${response.statusCode}',
        //   description:
        //       'Header: ${response.requestOptions.headers}\n\nBody: $jsonString\n\n Query: ${jsonEncode(response.requestOptions.queryParameters)}',
        //   message: jsonEncode(response.data),
        // );
      } else {
        // LogService.log(
        //   LogTag.api,
        //   title:
        //       '${response.requestOptions.method} ${response.requestOptions.path} ${response.statusCode}',
        //   description:
        //       'Header: ${response.requestOptions.headers}\n\nBody: ${jsonEncode(response.requestOptions.data)}\n\nQuery: ${jsonEncode(response.requestOptions.queryParameters)}',
        //   message: jsonEncode(response.data),
        // );
      }
    } catch (e) {
      Utils.debugLogError('Log error: $e');
    }

    final statusCode = response.statusCode.toString();

    // only handle if response is json
    if (response.data is! Map<String, dynamic>) {
      return handler.next(response);
    }
    final Map<String, dynamic> mapData = response.data;
    final isError = mapData['result'] == 'failed';
    //get extra from request.options?
    if (mapData['type'] == 'DIALOG') {
      final json = mapData;

      // AppDialog.showFromJson(json);
    } else {
      if (isError && response.requestOptions.extra['notShowError'] != true) {
        // final errorStr =
        //     mapData['reason'] ??
        //     mapData['message'] ??
        // AppKeys.navigatorKey.currentContext?.localization.unknown_error;

        // AppDialog.show(
        //   title:
        //       AppKeys.navigatorKey.currentContext?.localization.error_title ??
        //       '',
        //   type: AppDialogType.failed,
        //   message: errorStr,
        //   confirmText: AppKeys.navigatorKey.currentContext?.localization.close,
        // );
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final fullUrl = err.requestOptions.uri.toString();
    Utils.debugLogError(
      '${err.requestOptions.method} $fullUrl (baseUrl: ${err.requestOptions.baseUrl}, path: ${err.requestOptions.path}) body:${err.requestOptions.data} query:${err.requestOptions.queryParameters} status:${err.response?.statusCode?.toString()} error:${err.response?.data}',
    );

    try {
      if (err.requestOptions.headers['content-type']
              ?.toString()
              .toLowerCase()
              .contains('multipart/form-data') ==
          true) {
        final formData = err.requestOptions.data as FormData;
        final map = {
          for (var field in formData.fields) field.key: field.value,
          for (var file in formData.files)
            file.key: file.value.filename, // only filename
        };
        final jsonString = jsonEncode(map);

        // LogService.log(
        //   LogTag.api,
        //   title:
        //       '${err.requestOptions.method} ${err.requestOptions.path} ${err.response?.statusCode}',
        //   description:
        //       'Header: ${err.requestOptions.headers}\n\nBody: $jsonString\n\n Query: ${jsonEncode(err.requestOptions.queryParameters)}',
        //   message: jsonEncode(err.response?.data),
        // );
      } else {
        // emit to logs
        // LogService.log(
        //   LogTag.api,
        //   title:
        //       '${err.requestOptions.method} ${err.requestOptions.path} ${err.response?.statusCode}',
        //   description:
        //       'Header: ${err.requestOptions.headers}\n\nBody: ${jsonEncode(err.requestOptions.data)}\n\nQuery: ${jsonEncode(err.requestOptions.queryParameters)}',
        //   message: jsonEncode(err.response?.data),
        // );
      }
    } catch (e) {
      Utils.debugLogError('Log error: $e');
    }

    if (err.response?.data?['type'] == 'DIALOG') {
      final json = err.response?.data;

      // AppDialog.showFromJson(json);
    } else {
      /* show app dialog if error */
      if (err.requestOptions.extra['notShowError'] != true) {
        // final errorStr =
        //     err.response?.data['message'] ??
        //     err.response?.data['reason'] ??
        //     AppKeys.navigatorKey.currentContext?.localization.unknown_error;
        // AppDialog.show(
        //   title:
        //       AppKeys.navigatorKey.currentContext?.localization.error_title ??
        //       '',
        //   type: AppDialogType.failed,
        //   message: errorStr,
        //   confirmText: AppKeys.navigatorKey.currentContext?.localization.close,
        // );
      }
    }

    // check if 401 or 403, remove token and navigate to login
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      Utils.debugLogError('Unauthorized');
      // AuthBloc authBloc = Modular.get<AuthBloc>();
      // authBloc.add(AuthLogoutRequested(forceLogout: true));
    }

    return handler.reject(err);
  }
}
