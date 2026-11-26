import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/owner_repository.dart';
import 'owner_state.dart';

class OwnerCubit extends Cubit<OwnerState> {
  final OwnerRepository _repository;

  OwnerCubit(this._repository) : super(OwnerInitial());

  Future<void> loadDashboard() async {
    emit(OwnerLoading());
    try {
      final data = await _repository.getDashboard();
      if (isClosed) return;

      final vehicles = (data['vehicles'] as List<dynamic>?)?.cast<VehicleEntity>() ?? [];
      final primary = data['primary_vehicle'] as VehicleEntity?;
      final activeReq = primary?.activePickupRequest;
      final todaySched = data['today_schedule'] as Map<String, dynamic>?;

      emit(OwnerLoaded(
        primaryVehicle: primary ?? (vehicles.isNotEmpty ? vehicles.first : null),
        vehicles: vehicles,
        activeRequest: activeReq,
        isScheduleActiveToday: todaySched?['is_active_today'] as bool? ?? false,
        scheduleTimeToday: todaySched?['pickup_time'] as String?,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(OwnerError(e.toString()));
    }
  }

  void selectPrimaryVehicle(VehicleEntity vehicle) {
    if (state is OwnerLoaded) {
      final current = state as OwnerLoaded;
      emit(current.copyWith(
        primaryVehicle: vehicle,
        activeRequest: vehicle.activePickupRequest,
      ));
    }
  }

  Future<void> requestImmediatePickup({
    required int vehicleId,
    required bool wantsWash,
    String? washType,
    String? notes,
  }) async {
    try {
      await _repository.createPickupRequest(
        vehicleId: vehicleId,
        scheduledFor: null, // immediate
        wantsWash: wantsWash,
        washType: washType,
        ownerNotes: notes,
      );

      if (isClosed) return;
      await loadDashboard();
    } catch (e) {
      if (isClosed) return;
      emit(OwnerError(e.toString()));
    }
  }

  Future<void> cancelActiveRequest(int requestId) async {
    try {
      await _repository.cancelPickupRequest(requestId);
      if (isClosed) return;
      await loadDashboard();
    } catch (e) {
      if (isClosed) return;
      emit(OwnerError(e.toString()));
    }
  }

  Future<void> saveSchedule({
    required int vehicleId,
    required String pickupTime,
    required List<int> excludedDays,
    required bool includeWash,
    required String washType,
    required bool isActive,
    String? skipDate,
  }) async {
    try {
      await _repository.upsertDailySchedule(
        vehicleId: vehicleId,
        pickupTime: pickupTime,
        excludedDays: excludedDays,
        includeWash: includeWash,
        washType: washType,
        isActive: isActive,
        skipDate: skipDate,
      );

      if (isClosed) return;
      await loadDashboard();
    } catch (e) {
      if (isClosed) return;
      emit(OwnerError(e.toString()));
    }
  }

  Future<void> addNewVehicle({
    required String make,
    required String model,
    int? year,
    required String colorName,
    required String colorHex,
    required String plateLetters,
    required String plateNumbers,
    String? specialNotes,
  }) async {
    try {
      await _repository.addVehicle(
        make: make,
        model: model,
        year: year,
        colorName: colorName,
        colorHex: colorHex,
        plateLetters: plateLetters,
        plateNumbers: plateNumbers,
        specialNotes: specialNotes,
      );

      if (isClosed) return;
      await loadDashboard();
    } catch (e) {
      if (isClosed) return;
      emit(OwnerError(e.toString()));
    }
  }
}
