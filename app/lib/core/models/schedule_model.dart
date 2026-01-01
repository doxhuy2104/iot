import 'package:equatable/equatable.dart';

class ScheduleModel extends Equatable {
  final int? id;
  final int? zoneId;
  final String? startTime;
  final int? durationMinutes;
  final List<String>? repeatDays;
  final bool? active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleModel({
    this.id,
    this.zoneId,
    this.startTime,
    this.durationMinutes,
    this.repeatDays,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  static ScheduleModel? fromJson(Map<String, dynamic>? mapData) {
    if (mapData == null) return null;

    final int? id = mapData['schedule_id'] ?? mapData['id'];
    final int? zoneId = mapData['zone_id'] ?? mapData['zoneId'];
    final String? startTime = mapData['start_time'] ?? mapData['startTime'];
    final int? durationMinutes =
        mapData['duration_minutes'] ??
        mapData['duration_min'] ??
        mapData['durationMinutes'];
    // backend: repeat_days lưu String, ví dụ "MON,TUE"
    List<String>? repeatDays;
    if (mapData['repeat_days'] is String) {
      final raw = (mapData['repeat_days'] as String).trim();
      repeatDays = raw.isEmpty
          ? []
          : raw.split(',').map((e) => e.trim()).toList();
    } else if (mapData['repeat_days'] is List) {
      repeatDays = List<String>.from(mapData['repeat_days']);
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
      durationMinutes: durationMinutes,
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
    'duration_minutes': durationMinutes,
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
    int? durationMinutes,
    List<String>? repeatDays,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
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
    durationMinutes,
    repeatDays,
    active,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Schedule(id: $id, zoneId: $zoneId, startTime: $startTime, durationMinutes: $durationMinutes, repeatDays: $repeatDays, active: $active, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
