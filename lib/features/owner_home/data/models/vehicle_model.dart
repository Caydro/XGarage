import '../../domain/entities/vehicle_entity.dart';
import 'daily_schedule_model.dart';
import 'pickup_request_model.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.make,
    required super.model,
    super.year,
    required super.colorName,
    required super.colorHex,
    required super.plateLetters,
    required super.plateNumbers,
    required super.plateFullNormalized,
    super.plateImagePath,
    super.parkingSpot,
    super.keyHookNumber,
    super.specialNotes,
    required super.currentStatus,
    required super.isInsideGarage,
    super.ownerName,
    super.dailySchedule,
    super.activePickupRequest,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      make: json['make'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: json['year'] as int?,
      colorName: json['color_name'] as String? ?? 'Black',
      colorHex: json['color_hex'] as String? ?? '#0F0E13',
      plateLetters: json['plate_letters'] as String? ?? '',
      plateNumbers: json['plate_numbers'] as String? ?? '',
      plateFullNormalized: json['plate_full_normalized'] as String? ?? '',
      plateImagePath: json['plate_image_path'] as String?,
      parkingSpot: json['parking_spot'] as String?,
      keyHookNumber: json['key_hook_number'] as String?,
      specialNotes: json['special_notes'] as String?,
      currentStatus: json['current_status'] as String? ?? 'parked',
      isInsideGarage: json['is_inside_garage'] as bool? ?? true,
      ownerName: json['owner_name'] as String? ??
          (json['owner'] is Map
              ? (json['owner'] as Map)['name'] as String?
              : null),
      dailySchedule: json['daily_schedule'] != null
          ? DailyScheduleModel.fromJson(json['daily_schedule'] as Map<String, dynamic>)
          : null,
      activePickupRequest: json['active_pickup_request'] != null
          ? PickupRequestModel.fromJson(json['active_pickup_request'] as Map<String, dynamic>)
          : null,
    );
  }
}
