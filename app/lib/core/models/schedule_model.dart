import 'package:equatable/equatable.dart';

class ScheduleModel extends Equatable {
  final int? id;
  final int? zoneId;
  final String? startTime;
  final int? duration;
  final double? volume;
  final List<String>? repeatDays;
  final bool? active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleModel({
    this.id,
    this.zoneId,
    this.startTime,
    this.duration,
    this.volume,
    this.repeatDays,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  static ScheduleModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id =
        mapData['schedule_id'] ?? mapData['scheduleId'] ?? mapData['id'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final String? startTime = mapData['start_time'] ?? mapData['startTime'];
    final int? duration =
        mapData['duration'] ??
        mapData['duration_seconds'] ??
        mapData['durationSeconds'];
    final double? volume = (mapData['volume'] as num?)?.toDouble();

    // backend: repeat_days lưu String, ví dụ "MON,TUE"
    List<String>? repeatDays;
    // Check snake_case key
    if (mapData['repeat_days'] is String) {
      final raw = (mapData['repeat_days'] as String).trim();
      repeatDays = raw.isEmpty
          ? []
          : raw.split(',').map((e) => e.trim()).toList();
    } else if (mapData['repeat_days'] is List) {
      repeatDays = List<String>.from(mapData['repeat_days']);
    }
    // Check camelCase key
    else if (mapData['repeatDays'] is String) {
      final raw = (mapData['repeatDays'] as String).trim();
      repeatDays = raw.isEmpty
          ? []
          : raw.split(',').map((e) => e.trim()).toList();
    } else if (mapData['repeatDays'] is List) {
      repeatDays = List<String>.from(mapData['repeatDays']);
    }
    final bool? active = mapData['active'];
    final DateTime? createdAt = mapData['created_at'] != null
        ? (mapData['created_at'] is DateTime
              ? mapData['created_at']
              : DateTime.tryParse(mapData['created_at'].toString()))
        : null;
    final DateTime? updatedAt = mapData['updated_at'] != null
        ? (mapData['updated_at'] is DateTime
              ? mapData['updated_at']
              : DateTime.tryParse(mapData['updated_at'].toString()))
        : null;

    return ScheduleModel(
      id: id,
      zoneId: zoneId,
      startTime: startTime,
      duration: duration,
      volume: volume,
      repeatDays: repeatDays,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'schedule_id': id,
    'zone_id': zoneId,
    'start_time': startTime,
    'duration': duration,
    'volume': volume,
    // ghi lại dạng "MON,TUE" cho backend
    'repeat_days': repeatDays?.join(','),
    'active': active,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  ScheduleModel copyWith({
    int? id,
    int? zoneId,
    String? startTime,
    int? duration,
    double? volume,
    List<String>? repeatDays,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      repeatDays: repeatDays ?? this.repeatDays,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    zoneId,
    startTime,
    duration,
    volume,
    repeatDays,
    active,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Schedule(id: $id, zoneId: $zoneId, startTime: $startTime, duration: $duration, volume: $volume, repeatDays: $repeatDays, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
