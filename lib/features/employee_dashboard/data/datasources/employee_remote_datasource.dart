import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/garage_summary_model.dart';
import '../models/queue_item_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<QueueItemModel>> getQueue({String filter = 'all', String? search});
  Future<GarageSummaryModel> getSummary();
  Future<void> updateSpot(int vehicleId, Map<String, dynamic> data);
  Future<void> updateStatus(int vehicleId, Map<String, dynamic> data);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final ApiClient _apiClient;

  EmployeeRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<QueueItemModel>> getQueue({String filter = 'all', String? search}) async {
    final query = <String, dynamic>{'filter': filter};
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    final response = await _apiClient.get(ApiEndpoints.employeeQueue, queryParameters: query);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => QueueItemModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<GarageSummaryModel> getSummary() async {
    final response = await _apiClient.get(ApiEndpoints.employeeQueueSummary);
    return GarageSummaryModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateSpot(int vehicleId, Map<String, dynamic> data) async {
    await _apiClient.patch(ApiEndpoints.employeeVehicleSpot(vehicleId), data: data);
  }

  @override
  Future<void> updateStatus(int vehicleId, Map<String, dynamic> data) async {
    await _apiClient.patch(ApiEndpoints.employeeVehicleStatus(vehicleId), data: data);
  }
}
