import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/garage_summary_entity.dart';
import '../../domain/entities/queue_item_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource _remoteDataSource;

  EmployeeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<QueueItemEntity>> getQueue({String filter = 'all', String? search}) async {
    try {
      return await _remoteDataSource.getQueue(filter: filter, search: search);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<GarageSummaryEntity> getSummary() async {
    try {
      return await _remoteDataSource.getSummary();
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateSpot({
    required int vehicleId,
    required String spot,
    String? keyHook,
  }) async {
    try {
      await _remoteDataSource.updateSpot(vehicleId, {
        'parking_spot': spot,
        if (keyHook != null) 'key_hook_number': keyHook,
      });
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateStatus({
    required int vehicleId,
    required String status,
    String? washStatus,
    String? notes,
  }) async {
    try {
      await _remoteDataSource.updateStatus(vehicleId, {
        'status': status,
        if (washStatus != null) 'wash_status': washStatus,
        if (notes != null) 'notes': notes,
      });
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
