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
      await _tokenStorage.saveUserMeta(
        id: user.id,
        name: user.name,
        role: user.role,
        phone: user.phone,
        email: user.email,
        avatarUrl: user.avatarUrl,
      );
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
      await _tokenStorage.saveUserMeta(
        id: user.id,
        name: user.name,
        role: user.role,
        phone: user.phone,
        email: user.email,
        avatarUrl: user.avatarUrl,
      );
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

      final cachedUser = _tokenStorage.getCachedUser();

      try {
        final freshUser = await _remoteDataSource
            .getMe()
            .timeout(const Duration(seconds: 4));
        await _tokenStorage.saveUserMeta(
          id: freshUser.id,
          name: freshUser.name,
          role: freshUser.role,
          phone: freshUser.phone,
          email: freshUser.email,
          avatarUrl: freshUser.avatarUrl,
        );
        return freshUser;
      } catch (_) {
        if (cachedUser != null) {
          return cachedUser;
        }
        return null;
      }
    } catch (_) {
      return _tokenStorage.getCachedUser();
    }
  }

  @override
  Future<UserEntity> updateProfile({
    required String name,
    required String phone,
    String? email,
    String? password,
  }) async {
    try {
      final payload = {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
      };

      final updatedUser = await _remoteDataSource.updateProfile(payload);
      await _tokenStorage.saveUserMeta(
        id: updatedUser.id,
        name: updatedUser.name,
        role: updatedUser.role,
        phone: updatedUser.phone,
        email: updatedUser.email,
        avatarUrl: updatedUser.avatarUrl,
      );
      return updatedUser;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> updateAvatar(String filePath) async {
    try {
      final updatedUser = await _remoteDataSource.updateAvatar(filePath);
      await _tokenStorage.saveUserMeta(
        id: updatedUser.id,
        name: updatedUser.name,
        role: updatedUser.role,
        phone: updatedUser.phone,
        email: updatedUser.email,
        avatarUrl: updatedUser.avatarUrl,
      );
      return updatedUser;
    } on ServerException catch (e) {
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      throw ServerFailure(e.toString());
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
