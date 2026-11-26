import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/daily_schedule_model.dart';
import '../models/pickup_request_model.dart';
import '../models/vehicle_model.dart';

abstract class OwnerRemoteDataSource {
  Future<Map<String, dynamic>> getDashboard();
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> addVehicle(Map<String, dynamic> data);
  Future<DailyScheduleModel> upsertDailySchedule(int vehicleId, Map<String, dynamic> data);
  Future<PickupRequestModel> createPickupRequest(int vehicleId, Map<String, dynamic> data);
  Future<PickupRequestModel> cancelPickupRequest(int requestId);
}

class OwnerRemoteDataSourceImpl implements OwnerRemoteDataSource {
  final ApiClient _apiClient;

  OwnerRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.ownerDashboard);
    return response['data'] as Map<String, dynamic>;
  }

  @override
  Future<List<VehicleModel>> getVehicles() async {
    final response = await _apiClient.get(ApiEndpoints.ownerVehicles);
    final data = response['data'] as List<dynamic>;
    return data.map((json) => VehicleModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<VehicleModel> addVehicle(Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.ownerVehicles, data: data);
    return VehicleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<DailyScheduleModel> upsertDailySchedule(int vehicleId, Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiEndpoints.ownerDailySchedule(vehicleId), data: data);
    return DailyScheduleModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PickupRequestModel> createPickupRequest(int vehicleId, Map<String, dynamic> data) async {
    final response = await _apiClient.post(ApiEndpoints.ownerPickupRequests(vehicleId), data: data);
    return PickupRequestModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<PickupRequestModel> cancelPickupRequest(int requestId) async {
    final response = await _apiClient.patch(ApiEndpoints.ownerCancelPickupRequest(requestId));
    return PickupRequestModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
