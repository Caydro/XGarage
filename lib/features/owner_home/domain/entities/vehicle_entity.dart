import 'package:equatable/equatable.dart';
import 'daily_schedule_entity.dart';
import 'pickup_request_entity.dart';

class VehicleEntity extends Equatable {
  final int id;
  final int userId;
  final String make;
  final String model;
  final int? year;
  final String colorName;
  final String colorHex;
  final String plateLetters;
  final String plateNumbers;
  final String plateFullNormalized;
  final String? plateImagePath;
  final String? parkingSpot;
  final String? keyHookNumber;
  final String? specialNotes;
  final String currentStatus; // parked, preparing, washing, ready_at_gate, checked_out
  final bool isInsideGarage;
  final String? ownerName;
  final DailyScheduleEntity? dailySchedule;
  final PickupRequestEntity? activePickupRequest;

  const VehicleEntity({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    this.year,
    required this.colorName,
    required this.colorHex,
    required this.plateLetters,
    required this.plateNumbers,
    required this.plateFullNormalized,
    this.plateImagePath,
    this.parkingSpot,
    this.keyHookNumber,
    this.specialNotes,
    required this.currentStatus,
    required this.isInsideGarage,
    this.ownerName,
    this.dailySchedule,
    this.activePickupRequest,
  });

  String get displayName => '$make $model ${year ?? ''}'.trim();

  @override
  List<Object?> get props => [
        id,
        userId,
        make,
        model,
        year,
        colorName,
        colorHex,
        plateLetters,
        plateNumbers,
        plateFullNormalized,
        plateImagePath,
        ownerName,
        parkingSpot,
        keyHookNumber,
        specialNotes,
        currentStatus,
        isInsideGarage,
        dailySchedule,
        activePickupRequest,
      ];
}
