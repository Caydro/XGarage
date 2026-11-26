import 'package:equatable/equatable.dart';

class DailyScheduleEntity extends Equatable {
  final int id;
  final int vehicleId;
  final String pickupTime; // 'HH:MM'
  final List<int> excludedDays; // 0=Sun..5=Fri..6=Sat
  final bool includeWash;
  final String washType; // none, exterior, full
  final bool isActive;
  final String? skipDate;

  const DailyScheduleEntity({
    required this.id,
    required this.vehicleId,
    required this.pickupTime,
    required this.excludedDays,
    required this.includeWash,
    required this.washType,
    required this.isActive,
    this.skipDate,
  });

  bool isExcluded(int weekdayIndex) => excludedDays.contains(weekdayIndex);

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        pickupTime,
        excludedDays,
        includeWash,
        washType,
        isActive,
        skipDate,
      ];
}
