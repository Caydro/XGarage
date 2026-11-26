import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/daily_schedule_entity.dart';
import '../../domain/entities/pickup_request_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/owner_repository.dart';
import '../datasources/owner_remote_datasource.dart';
import '../models/vehicle_model.dart';

class OwnerRepositoryImpl implements OwnerRepository {
  final OwnerRemoteDataSource _remoteDataSource;

  OwnerRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final raw = await _remoteDataSource.getDashboard();
      final vehiclesJson = raw['vehicles'] as List<dynamic>? ?? [];
      final vehicles = vehiclesJson
          .map((v) => VehicleModel.fromJson(v as Map<String, dynamic>))
          .toList();

      return {
        'primary_vehicle': raw['primary_vehicle'] != null
            ? VehicleModel.fromJson(raw['primary_vehicle'] as Map<String, dynamic>)
            : null,
        'vehicles': vehicles,
        'active_request': raw['active_request'] != null
            ? VehicleModel.fromJson(raw['primary_vehicle'] as Map<String, dynamic>).activePickupRequest
            : null,
        'today_schedule': raw['today_schedule'],
      };
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<VehicleEntity>> getVehicles() async {
    try {
      return await _remoteDataSource.getVehicles();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<VehicleEntity> addVehicle({
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
      return await _remoteDataSource.addVehicle({
        'make': make,
        'model': model,
        if (year != null) 'year': year,
        'color_name': colorName,
        'color_hex': colorHex,
        'plate_letters': plateLetters,
        'plate_numbers': plateNumbers,
        if (specialNotes != null) 'special_notes': specialNotes,
      });
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<VehicleEntity> updateVehicle({
    required int vehicleId,
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
      return await _remoteDataSource.updateVehicle(vehicleId, {
        'make': make,
        'model': model,
        if (year != null) 'year': year,
        'color_name': colorName,
        'color_hex': colorHex,
        'plate_letters': plateLetters,
        'plate_numbers': plateNumbers,
        if (specialNotes != null) 'special_notes': specialNotes,
      });
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<DailyScheduleEntity> upsertDailySchedule({
    required int vehicleId,
    required String pickupTime,
    required List<int> excludedDays,
    required bool includeWash,
    required String washType,
    required bool isActive,
    String? skipDate,
  }) async {
    try {
      return await _remoteDataSource.upsertDailySchedule(vehicleId, {
        'pickup_time': pickupTime,
        'excluded_days': excludedDays,
        'include_wash': includeWash,
        'wash_type': washType,
        'is_active': isActive,
        if (skipDate != null) 'skip_date': skipDate,
      });
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PickupRequestEntity> createPickupRequest({
    required int vehicleId,
    DateTime? scheduledFor,
    required bool wantsWash,
    String? washType,
    String? ownerNotes,
  }) async {
    try {
      return await _remoteDataSource.createPickupRequest(vehicleId, {
        if (scheduledFor != null) 'scheduled_for': scheduledFor.toIso8601String(),
        'wants_wash': wantsWash,
        if (washType != null) 'wash_type': washType,
        if (ownerNotes != null) 'owner_notes': ownerNotes,
      });
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PickupRequestEntity> cancelPickupRequest(int requestId) async {
    try {
      return await _remoteDataSource.cancelPickupRequest(requestId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
