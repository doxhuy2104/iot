import 'package:app/core/models/zone_model.dart';
import 'package:app/core/network/dio_exceptions.dart';
import 'package:app/core/network/dio_failure.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/zone/data/datasources/zone_api.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class ZoneRepository {
  final ZoneApi api;

  ZoneRepository({required this.api});

  Future<Either<DioFailure, List<ZoneModel>>> getZones() async {
    try {
      final response = await api.getZones();
      final data = response.data;
      Utils.debugLog(data);
      List<dynamic> listData = [];
      if (data is Map<String, dynamic> && data['data'] is List) {
        listData = data['data'];
      } else if (data is List) {
        listData = data;
      }
      final zones = List<ZoneModel>.from(
        listData.map((e) => ZoneModel.fromJson(e)),
      );
      return Right(zones);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, Map<String, dynamic>>> sendWifi({
    required String ssid,
    required String password,
  }) async {
    try {
      final response = await api.sendWifi(ssid, password);

      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, dynamic>> createZone({
    required String zoneName,
    String? location,
    String? description,
    String? longitude,
    String? latitude,
    double? thresholdValue,
    bool? autoMode,
    bool? weatherMode,
  }) async {
    try {
      final data = {
        'zoneName': zoneName,
        'location': location,
        'description': description,
        'longitude': longitude,
        'latitude': latitude,
        'thresholdValue': thresholdValue,
        'autoMode': autoMode,
        'weatherMode': weatherMode,
      };
      // Remove null values if API doesn't except them, or keep them if it does.
      // Usually better to keep keys but value is null, or remove key.
      // I'll leave them as is, assuming API handles nulls.
      // However, Java primitives (boolean) might not like nulls if not wrapper classes.
      // Java Request uses Boolean (wrapper), so null is okay.

      final response = await api.createZone(data);
      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, dynamic>> createDevice({
    required String deviceName,
    required int zoneId,
    required String type,
    required String identifier,
    // String? mqttTopicPublish,
    // String? mqttTopicSubscribe,
  }) async {
    try {
      final data = {
        'deviceName': deviceName,
        'zoneId': zoneId,
        'type': type,
        'identifier': identifier,
        // 'mqttTopicPublish': mqttTopicPublish,
        // 'mqttTopicSubscribe': mqttTopicSubscribe,
      };
      final response = await api.createDevice(data);
      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, dynamic>> deleteZone(int id) async {
    try {
      final response = await api.deleteZone(id);
      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, ZoneModel>> updateZone({
    required int id,
    String? zoneName,
    double? location,
    String? description,
    String? longitude,
    double? latitude,
    double? thresholdValue,
    bool? autoMode,
    bool? weatherMode,
    bool? pumpStatus,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (zoneName != null) data['zoneName'] = zoneName;
      if (location != null) data['location'] = location;
      if (description != null) data['description'] = description;
      if (longitude != null) data['longitude'] = longitude;
      if (latitude != null) data['latitude'] = latitude;
      if (thresholdValue != null) data['thresholdValue'] = thresholdValue;
      if (autoMode != null) data['autoMode'] = autoMode;
      if (weatherMode != null) data['weatherMode'] = weatherMode;
      if (pumpStatus != null) data['pumpStatus'] = pumpStatus;

      final response = await api.updateZone(id, data);
      final responseData = response.data;
      final mapData = responseData is Map<String, dynamic>
          ? (responseData['data'] is Map<String, dynamic>
                ? responseData['data']
                : responseData)
          : responseData;

      return Right(ZoneModel.fromJson(mapData)!);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }
}
