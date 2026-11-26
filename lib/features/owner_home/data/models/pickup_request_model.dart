import '../../domain/entities/pickup_request_entity.dart';

class PickupRequestModel extends PickupRequestEntity {
  const PickupRequestModel({
    required super.id,
    required super.vehicleId,
    required super.source,
    required super.scheduledFor,
    required super.wantsWash,
    required super.washType,
    required super.washStatus,
    required super.status,
    super.ownerNotes,
    super.readyAt,
    super.pickedUpAt,
  });

  factory PickupRequestModel.fromJson(Map<String, dynamic> json) {
    return PickupRequestModel(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int,
      source: json['source'] as String? ?? 'manual',
      scheduledFor: DateTime.tryParse(json['scheduled_for'] as String? ?? '') ?? DateTime.now(),
      wantsWash: json['wants_wash'] as bool? ?? false,
      washType: json['wash_type'] as String? ?? 'none',
      washStatus: json['wash_status'] as String? ?? 'not_needed',
      status: json['status'] as String? ?? 'scheduled',
      ownerNotes: json['owner_notes'] as String?,
      readyAt: json['ready_at'] != null ? DateTime.tryParse(json['ready_at'] as String) : null,
      pickedUpAt: json['picked_up_at'] != null ? DateTime.tryParse(json['picked_up_at'] as String) : null,
    );
  }
}
