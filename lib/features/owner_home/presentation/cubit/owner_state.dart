import 'package:equatable/equatable.dart';
import '../../domain/entities/pickup_request_entity.dart';
import '../../domain/entities/vehicle_entity.dart';

sealed class OwnerState extends Equatable {
  const OwnerState();

  @override
  List<Object?> get props => [];
}

class OwnerInitial extends OwnerState {}

class OwnerLoading extends OwnerState {}

class OwnerLoaded extends OwnerState {
  final VehicleEntity? primaryVehicle;
  final List<VehicleEntity> vehicles;
  final PickupRequestEntity? activeRequest;
  final bool isScheduleActiveToday;
  final String? scheduleTimeToday;
  final String? actionMessage;

  const OwnerLoaded({
    required this.primaryVehicle,
    required this.vehicles,
    this.activeRequest,
    this.isScheduleActiveToday = false,
    this.scheduleTimeToday,
    this.actionMessage,
  });

  OwnerLoaded copyWith({
    VehicleEntity? primaryVehicle,
    List<VehicleEntity>? vehicles,
    PickupRequestEntity? activeRequest,
    bool? isScheduleActiveToday,
    String? scheduleTimeToday,
    String? actionMessage,
  }) {
    return OwnerLoaded(
      primaryVehicle: primaryVehicle ?? this.primaryVehicle,
      vehicles: vehicles ?? this.vehicles,
      activeRequest: activeRequest ?? this.activeRequest,
      isScheduleActiveToday: isScheduleActiveToday ?? this.isScheduleActiveToday,
      scheduleTimeToday: scheduleTimeToday ?? this.scheduleTimeToday,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        primaryVehicle,
        vehicles,
        activeRequest,
        isScheduleActiveToday,
        scheduleTimeToday,
        actionMessage,
      ];
}

class OwnerError extends OwnerState {
  final String message;

  const OwnerError(this.message);

  @override
  List<Object?> get props => [message];
}
