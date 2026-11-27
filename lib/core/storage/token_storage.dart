import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user_entity.dart';

class TokenStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyLocale = 'app_locale';
  static const String _keyBaseUrl = 'custom_base_url';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  TokenStorage({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> saveUserMeta({
    required int id,
    required String name,
    required String role,
    String? phone,
    String? email,
    String? avatarUrl,
  }) async {
    await _prefs.setInt(_keyUserId, id);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyRole, role);
    if (phone != null && phone.isNotEmpty) {
      await _prefs.setString(_keyUserPhone, phone);
    }
    if (email != null && email.isNotEmpty) {
      await _prefs.setString(_keyUserEmail, email);
    } else if (email == null) {
      await _prefs.remove(_keyUserEmail);
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await _prefs.setString(_keyUserAvatar, avatarUrl);
    } else if (avatarUrl == null) {
      await _prefs.remove(_keyUserAvatar);
    }
  }

  UserEntity? getCachedUser() {
    final id = _prefs.getInt(_keyUserId);
    final name = _prefs.getString(_keyUserName);
    final role = _prefs.getString(_keyRole);
    if (id == null || name == null || role == null) return null;

    return UserEntity(
      id: id,
      name: name,
      phone: _prefs.getString(_keyUserPhone) ?? '',
      email: _prefs.getString(_keyUserEmail),
      role: role,
      avatarUrl: _prefs.getString(_keyUserAvatar),
      locale: getLocale(),
    );
  }

  String? getRole() {
    return _prefs.getString(_keyRole);
  }

  int? getUserId() {
    return _prefs.getInt(_keyUserId);
  }

  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  Future<void> saveLocale(String localeCode) async {
    await _prefs.setString(_keyLocale, localeCode);
  }

  String getLocale() {
    return _prefs.getString(_keyLocale) ?? 'ar';
  }

  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  String? getSavedBaseUrl() {
    return _prefs.getString(_keyBaseUrl);
  }

  Future<void> clear() async {
    await _secureStorage.delete(key: _keyToken);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserPhone);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserAvatar);
  }
}
