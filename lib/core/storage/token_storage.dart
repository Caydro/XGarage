import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
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
  }) async {
    await _prefs.setInt(_keyUserId, id);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyRole, role);
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
  }
}
