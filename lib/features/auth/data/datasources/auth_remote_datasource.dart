import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<(UserModel, String)> login({required String login, required String password});
  Future<(UserModel, String)> register(Map<String, dynamic> payload);
  Future<UserModel> getMe();
  Future<UserModel> updateProfile(Map<String, dynamic> payload);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<(UserModel, String)> login({required String login, required String password}) async {
    final response = await _apiClient.post(ApiEndpoints.login, data: {
      'login': login,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    return (user, token);
  }

  @override
  Future<(UserModel, String)> register(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.register, data: payload);
    final data = response['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    return (user, token);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    final response = await _apiClient.put(ApiEndpoints.updateProfile, data: payload);
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(ApiEndpoints.logout);
  }
}
