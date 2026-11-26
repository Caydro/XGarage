import '../../domain/entities/queue_item_entity.dart';

class QueueItemModel extends QueueItemEntity {
  const QueueItemModel({
    required super.id,
    required super.vehicleId,
    required super.scheduledFor,
    required super.scheduledTime,
    required super.source,
    required super.isFromSchedule,
    required super.wantsWash,
    required super.washType,
    required super.washStatus,
    required super.status,
    super.ownerNotes,
    super.readyAt,
    required super.make,
    required super.model,
    super.year,
    required super.colorName,
    required super.colorHex,
    required super.plateLetters,
    required super.plateNumbers,
    super.parkingSpot,
    super.keyHookNumber,
    required super.currentStatus,
    required super.ownerName,
    required super.ownerPhone,
  });

  factory QueueItemModel.fromJson(Map<String, dynamic> json) {
    final v = json['vehicle'] as Map<String, dynamic>? ?? {};

    return QueueItemModel(
      id: json['id'],
      vehicleId: json['vehicle_id'] as int? ?? (v['id'] as int? ?? 0),
      scheduledFor: DateTime.tryParse(json['scheduled_for'] as String? ?? '') ?? DateTime.now(),
      scheduledTime: json['scheduled_time'] as String? ?? '09:00',
      source: json['source'] as String? ?? 'manual',
      isFromSchedule: json['is_from_schedule'] as bool? ?? false,
      wantsWash: json['wants_wash'] as bool? ?? false,
      washType: json['wash_type'] as String? ?? 'none',
      washStatus: json['wash_status'] as String? ?? 'not_needed',
      status: json['status'] as String? ?? 'scheduled',
      ownerNotes: json['owner_notes'] as String?,
      readyAt: json['ready_at'] != null ? DateTime.tryParse(json['ready_at'] as String) : null,
      make: v['make'] as String? ?? 'Vehicle',
      model: v['model'] as String? ?? '',
      year: v['year'] as int?,
      colorName: v['color_name'] as String? ?? 'Black',
      colorHex: v['color_hex'] as String? ?? '#0F0E13',
      plateLetters: v['plate_letters'] as String? ?? '',
      plateNumbers: v['plate_numbers'] as String? ?? '',
      parkingSpot: v['parking_spot'] as String?,
      keyHookNumber: v['key_hook_number'] as String?,
      currentStatus: v['current_status'] as String? ?? 'parked',
      ownerName: v['owner_name'] as String? ?? 'Customer',
      ownerPhone: v['owner_phone'] as String? ?? '',
    );
  }
}
