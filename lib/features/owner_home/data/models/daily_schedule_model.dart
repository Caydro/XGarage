import '../../domain/entities/daily_schedule_entity.dart';

class DailyScheduleModel extends DailyScheduleEntity {
  const DailyScheduleModel({
    required super.id,
    required super.vehicleId,
    required super.pickupTime,
    required super.excludedDays,
    required super.includeWash,
    required super.washType,
    required super.isActive,
    super.skipDate,
  });

  factory DailyScheduleModel.fromJson(Map<String, dynamic> json) {
    return DailyScheduleModel(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int,
      pickupTime: json['pickup_time'] as String? ?? '09:00',
      excludedDays: (json['excluded_days'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [5],
      includeWash: json['include_wash'] as bool? ?? false,
      washType: json['wash_type'] as String? ?? 'none',
      isActive: json['is_active'] as bool? ?? true,
      skipDate: json['skip_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pickup_time': pickupTime,
      'excluded_days': excludedDays,
      'include_wash': includeWash,
      'wash_type': washType,
      'is_active': isActive,
      'skip_date': skipDate,
    };
  }
}
