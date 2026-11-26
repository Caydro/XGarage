import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'XGarage';
  static const String appVersion = '1.0.0';

  static String? _activeBaseUrl;

  static void init([String? savedUrl]) {
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _activeBaseUrl = savedUrl;
    }
  }

  /// Candidate backend URLs in priority order.
  /// 1. Laragon Apache (port 80) serving /garage_back/public/api/v1 (The user's active Laragon setup!)
  /// 2. PHP Artisan Serve (port 8000) at /api/v1
  /// 3. Local Wi-Fi network IP for physical devices
  static List<String> get candidateUrls {
    if (!kIsWeb && Platform.isAndroid) {
      return const [
        'http://10.0.2.2/garage_back/public/api/v1',
        'http://10.0.2.2:8000/api/v1',
        'http://192.168.1.25/garage_back/public/api/v1',
      ];
    }
    return const [
      'http://127.0.0.1/garage_back/public/api/v1',
      'http://127.0.0.1:8000/api/v1',
      'http://localhost/garage_back/public/api/v1',
    ];
  }

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (_activeBaseUrl != null && _activeBaseUrl!.isNotEmpty) {
      return _activeBaseUrl!;
    }
    return candidateUrls.first;
  }

  static void setBaseUrl(String url) {
    _activeBaseUrl = url;
  }

  static const int connectTimeoutSeconds = 10;
  static const int receiveTimeoutSeconds = 12;
}
