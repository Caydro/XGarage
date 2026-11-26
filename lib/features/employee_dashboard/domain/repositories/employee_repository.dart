import '../entities/garage_summary_entity.dart';
import '../entities/queue_item_entity.dart';

abstract class EmployeeRepository {
  Future<List<QueueItemEntity>> getQueue({String filter = 'all', String? search});
  Future<GarageSummaryEntity> getSummary();
  Future<void> updateSpot({
    required int vehicleId,
    required String spot,
    String? keyHook,
  });
  Future<void> updateStatus({
    required int vehicleId,
    required String status,
    String? washStatus,
    String? notes,
  });
}
