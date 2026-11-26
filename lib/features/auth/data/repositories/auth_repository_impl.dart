import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  @override
  Future<UserEntity> login({required String login, required String password}) async {
    try {
      final (user, token) = await _remoteDataSource.login(login: login, password: password);
      await _tokenStorage.saveToken(token);
      await _tokenStorage.saveUserMeta(id: user.id, name: user.name, role: user.role);
      return user;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
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
  }) async {
    try {
      final payload = {
        'name': name,
        'phone': phone,
        'password': password,
        if (email != null) 'email': email,
        if (make != null) 'make': make,
        if (model != null) 'model': model,
        if (year != null) 'year': year,
        if (colorName != null) 'color_name': colorName,
        if (colorHex != null) 'color_hex': colorHex,
        if (plateLetters != null) 'plate_letters': plateLetters,
        if (plateNumbers != null) 'plate_numbers': plateNumbers,
      };

      final (user, token) = await _remoteDataSource.register(payload);
      await _tokenStorage.saveToken(token);
      await _tokenStorage.saveUserMeta(id: user.id, name: user.name, role: user.role);
      return user;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await _tokenStorage.getToken();
      if (token == null) return null;
      return await _remoteDataSource.getMe();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore network errors on logout to allow local cleanup
    } finally {
      await _tokenStorage.clear();
    }
  }
}
