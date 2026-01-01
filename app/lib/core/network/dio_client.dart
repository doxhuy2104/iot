import 'package:dio/dio.dart';
import 'package:app/core/network/dio_interceptor.dart';

final class DioClient {
  final String baseUrl;
  // receive timeout
  static const int receiveTimeout = 20;
  // connection timeout
  static const int connectionTimeout = 20;

  final Dio _dio;

  DioClient(this._dio, this.baseUrl) {
    _dio
      ..options.baseUrl = baseUrl
      ..options.connectTimeout = const Duration(seconds: connectionTimeout)
      ..options.receiveTimeout = const Duration(seconds: receiveTimeout)
      ..options.responseType = ResponseType.json
      ..interceptors.addAll([DioInterceptor(dio: _dio)]);
  }

  // method: get
  Future<Response> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      /* remove query with null value */
      if (queryParameters != null) {
        queryParameters.removeWhere((key, value) => value == null);
      }
      final Response response = await _dio.get(
        url,
        queryParameters: queryParameters,
        data: data,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// This Dart function sends a POST request with specified parameters and returns the response.
  ///
  /// Args:
  ///   url (String): The `url` parameter in the `post` function represents the endpoint URL where the
  /// HTTP POST request will be sent. It specifies the location where the data should be submitted or
  /// retrieved from.
  ///   baseUrl (String): The `baseUrl` parameter in the `post` function is used to specify the base URL
  /// that will be used for the HTTP request. If a `baseUrl` is provided, it will override the default
  /// base URL set in the `_dio` instance options for that specific request. This allows you to make
  ///   data (dynamic): The `data` parameter in the `post` function is used to send data in the request
  /// body when making a POST request. This data can be of various types such as a Map, List, String, or
  /// any other valid data type that you want to send to the server. It represents the
  ///   queryParameters (Map<String, dynamic>): The `queryParameters` parameter in the `post` function
  /// is a map that contains key-value pairs representing the query parameters to be sent with the HTTP
  /// POST request. These parameters are typically used to filter or customize the response from the
  /// server. For example, if you were making a request to retrieve a
  ///   options (Options): The `options` parameter in the `post` method allows you to specify additional
  /// configurations for the HTTP request being made. This parameter is of type `Options`, which
  /// typically includes settings such as headers, request timeout, response type, and more.
  ///   cancelToken (CancelToken): The `cancelToken` parameter in the `post` method is used to cancel
  /// the ongoing HTTP request. It is an optional parameter that allows you to provide a `CancelToken`
  /// object that can be used to cancel the request at any time.
  ///   onSendProgress (ProgressCallback): The `onSendProgress` parameter in the `post` method is a
  /// callback function that allows you to track the progress of sending data in the HTTP request. It
  /// can be used to monitor the progress of uploading data to the server. This callback function
  /// typically takes a `int sentBytes` parameter,
  ///   onReceiveProgress (ProgressCallback): The `onReceiveProgress` parameter in the `post` method is
  /// a callback function that allows you to track the progress of receiving data during the HTTP
  /// request. It can be used to monitor the progress of data being received from the server in
  /// real-time. This can be useful for displaying progress indicators or
  ///
  /// Returns:
  ///   The `post` method is returning a `Future<Response>`, which means it will return a `Response`
  /// object asynchronously after making a POST request using the Dio HTTP client.
  Future<Response> post(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.delete(
        url,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
