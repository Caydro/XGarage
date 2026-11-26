import '../config/app_config.dart';

/// Helper to safely resolve avatar image URLs for physical devices and emulators
String resolveAvatarUrl(String? url) {
  if (url == null || url.trim().isEmpty) return '';

  final currentBase = AppConfig.baseUrl;
  final baseUri = Uri.tryParse(currentBase);

  // If the backend returns localhost or 127.0.0.1, adapt it to the emulator/device host
  if (baseUri != null && (url.contains('localhost') || url.contains('127.0.0.1'))) {
    final avatarUri = Uri.tryParse(url);
    if (avatarUri != null) {
      return avatarUri
          .replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : avatarUri.port,
          )
          .toString();
    }
  }

  // If it's a relative path (e.g. "avatars/abc.jpg" or "/storage/avatars/abc.jpg")
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    final rootUrl = currentBase.replaceAll(RegExp(r'/api/v1/?$'), '');
    final cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return cleanPath.startsWith('storage/') ? '$rootUrl/$cleanPath' : '$rootUrl/storage/$cleanPath';
  }

  return url;
}
