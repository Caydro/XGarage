import '../entities/daily_schedule_entity.dart';
import '../entities/pickup_request_entity.dart';
import '../entities/vehicle_entity.dart';

abstract class OwnerRepository {
  Future<Map<String, dynamic>> getDashboard();
  Future<List<VehicleEntity>> getVehicles();
  Future<VehicleEntity> addVehicle({
    required String make,
    required String model,
    int? year,
    required String colorName,
    required String colorHex,
    required String plateLetters,
    required String plateNumbers,
    String? specialNotes,
  });
  Future<DailyScheduleEntity> upsertDailySchedule({
    required int vehicleId,
    required String pickupTime,
    required List<int> excludedDays,
    required bool includeWash,
    required String washType,
    required bool isActive,
    String? skipDate,
  });
  Future<PickupRequestEntity> createPickupRequest({
    required int vehicleId,
    DateTime? scheduledFor,
    required bool wantsWash,
    String? washType,
    String? ownerNotes,
  });
  Future<PickupRequestEntity> cancelPickupRequest(int requestId);
}
