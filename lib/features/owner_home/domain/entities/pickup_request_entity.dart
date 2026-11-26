import 'package:equatable/equatable.dart';

class PickupRequestEntity extends Equatable {
  final int id;
  final int vehicleId;
  final String source; // manual, daily_schedule
  final DateTime scheduledFor;
  final bool wantsWash;
  final String washType; // none, exterior, full
  final String washStatus; // not_needed, pending, in_progress, completed
  final String status; // scheduled, preparing, washing, ready_at_gate, completed, cancelled
  final String? ownerNotes;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;

  const PickupRequestEntity({
    required this.id,
    required this.vehicleId,
    required this.source,
    required this.scheduledFor,
    required this.wantsWash,
    required this.washType,
    required this.washStatus,
    required this.status,
    this.ownerNotes,
    this.readyAt,
    this.pickedUpAt,
  });

  bool get isReadyAtGate => status == 'ready_at_gate';
  bool get isWashing => status == 'washing';
  bool get isPreparing => status == 'preparing';
  bool get isScheduled => status == 'scheduled';

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        source,
        scheduledFor,
        wantsWash,
        washType,
        washStatus,
        status,
        ownerNotes,
        readyAt,
        pickedUpAt,
      ];
}
