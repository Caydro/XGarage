class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? data;

  const ServerException(this.message, [this.statusCode, this.data]);

  @override
  String toString() => 'ServerException: $message (code: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}
