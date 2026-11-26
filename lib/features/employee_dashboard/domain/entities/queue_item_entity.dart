import 'package:equatable/equatable.dart';

class QueueItemEntity extends Equatable {
  final dynamic id;
  final int vehicleId;
  final DateTime scheduledFor;
  final String scheduledTime; // 'HH:MM'
  final String source; // manual, daily_schedule
  final bool isFromSchedule;
  final bool wantsWash;
  final String washType; // none, exterior, full
  final String washStatus; // not_needed, pending, in_progress, completed
  final String status; // scheduled, preparing, washing, ready_at_gate, completed
  final String? ownerNotes;
  final DateTime? readyAt;

  // Embedded vehicle details
  final String make;
  final String model;
  final int? year;
  final String colorName;
  final String colorHex;
  final String plateLetters;
  final String plateNumbers;
  final String? parkingSpot;
  final String? keyHookNumber;
  final String currentStatus;
  final String ownerName;
  final String ownerPhone;

  const QueueItemEntity({
    required this.id,
    required this.vehicleId,
    required this.scheduledFor,
    required this.scheduledTime,
    required this.source,
    required this.isFromSchedule,
    required this.wantsWash,
    required this.washType,
    required this.washStatus,
    required this.status,
    this.ownerNotes,
    this.readyAt,
    required this.make,
    required this.model,
    this.year,
    required this.colorName,
    required this.colorHex,
    required this.plateLetters,
    required this.plateNumbers,
    this.parkingSpot,
    this.keyHookNumber,
    required this.currentStatus,
    required this.ownerName,
    required this.ownerPhone,
  });

  String get vehicleTitle => '$make $model ${year ?? ''}'.trim();
  bool get isReadyAtGate => currentStatus == 'ready_at_gate' || status == 'ready_at_gate';
  bool get isWashing => currentStatus == 'washing' || status == 'washing';

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        scheduledFor,
        scheduledTime,
        source,
        isFromSchedule,
        wantsWash,
        washType,
        washStatus,
        status,
        ownerNotes,
        readyAt,
        make,
        model,
        year,
        colorName,
        colorHex,
        plateLetters,
        plateNumbers,
        parkingSpot,
        keyHookNumber,
        currentStatus,
        ownerName,
        ownerPhone,
      ];
}
