import 'package:app/core/models/schedule_model.dart';
import 'package:app/core/models/water_log_model.dart';
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
    required int zoneId,
  }) async {
    try {
      final response = await api.sendWifi(ssid, password, zoneId);

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
    double? thresholdMin,
    double? thresholdMax,
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
        'thresholdMin': thresholdMin,
        'thresholdMax': thresholdMax,
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
    String? location,
    String? description,
    String? longitude,
    String? latitude,
    double? thresholdMin,
    double? thresholdMax,
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
      if (thresholdMin != null) data['thresholdMin'] = thresholdMin;
      if (thresholdMax != null) data['thresholdMax'] = thresholdMax;
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

  Future<Either<DioFailure, ZoneModel>> getZoneDetail(int id) async {
    try {
      final response = await api.getZoneDetail(id);
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

  Future<Either<DioFailure, dynamic>> startWatering({
    required int zoneId,
    required String pump,
    required int targetHumidity,
  }) async {
    try {
      final response = await api.startWatering(zoneId, pump, targetHumidity);
      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, List<WaterLogModel>>> getWaterLogs(
    int zoneId,
  ) async {
    try {
      final response = await api.getWaterLogs(zoneId);
      final responseData = response.data;
      final listData = responseData is Map<String, dynamic>
          ? (responseData['data'] as List)
          : responseData as List;

      final logs = List<WaterLogModel>.from(
        listData.map((e) => WaterLogModel.fromJson(e)),
      );
      return Right(logs);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, dynamic>> createSchedule({
    required int zoneId,
    required String startTime,
    required int duration,
    required double volume,
    required List<String> repeatDays,
    bool active = true,
  }) async {
    try {
      final data = {
        'zoneId': zoneId,
        'startTime': startTime,
        'duration': duration, // seconds
        'volume': volume,
        'repeatDays': repeatDays.join(','),
        'active': active,
      };

      final response = await api.createSchedule(data);
      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, List<ScheduleModel>>> getSchedules(
    int zoneId,
  ) async {
    try {
      final response = await api.getSchedules(zoneId);
      final responseData = response.data;
      // Handle generic response wrapper if exists, similar to getZones logic
      List<dynamic> listData = [];
      if (responseData is Map<String, dynamic> &&
          responseData['data'] is List) {
        listData = responseData['data'];
      } else if (responseData is List) {
        listData = responseData;
      }

      final schedules = List<ScheduleModel>.from(
        listData.map((e) => ScheduleModel.fromJson(e)),
      );
      return Right(schedules);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, dynamic>> deleteSchedule(int scheduleId) async {
    try {
      final response = await api.deleteSchedule(scheduleId);
      return Right(response.data);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }

  Future<Either<DioFailure, ScheduleModel>> toggleScheduleActive(
    int scheduleId,
    bool active,
  ) async {
    try {
      final response = await api.toggleScheduleActive(scheduleId, active);
      final responseData = response.data;
      final mapData = responseData is Map<String, dynamic>
          ? (responseData['data'] is Map<String, dynamic>
                ? responseData['data']
                : responseData)
          : responseData;
      return Right(ScheduleModel.fromJson(mapData)!);
    } on DioException catch (e) {
      final reason = DioExceptions.fromDioError(e).toString();
      final statusCode = e.response?.statusCode.toString() ?? '';
      return Left(ApiFailure(reason: reason, statusCode: statusCode));
    } catch (e) {
      return Left(ApiFailure(reason: e.toString(), statusCode: '400'));
    }
  }
}
