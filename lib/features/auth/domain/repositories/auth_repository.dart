import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String login, required String password});
  Future<UserEntity> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? make,
    String? model,
    int? year,
    String? colorName,
    String? colorHex,
    String? plateLetters,
    String? plateNumbers,
  });
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateProfile({
    required String name,
    required String phone,
    String? email,
    String? password,
  });
  Future<void> logout();
}
