import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({
    required TokenStorage tokenStorage,
    Dio? dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.baseUrl,
                connectTimeout: const Duration(seconds: AppConfig.connectTimeoutSeconds),
                receiveTimeout: const Duration(seconds: AppConfig.receiveTimeoutSeconds),
                headers: {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final locale = _tokenStorage.getLocale();
          options.headers['Accept-Language'] = locale;
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = newUrl;
    AppConfig.setBaseUrl(newUrl);
    _tokenStorage.saveBaseUrl(newUrl);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _executeWithFallback(
        () => _dio.get(path, queryParameters: queryParameters),
        method: 'GET',
        path: path,
        queryParameters: queryParameters,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _executeWithFallback(
        () => _dio.post(path, data: data),
        method: 'POST',
        path: path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _executeWithFallback(
        () => _dio.put(path, data: data),
        method: 'PUT',
        path: path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> patch(String path, {dynamic data}) async {
    try {
      final response = await _executeWithFallback(
        () => _dio.patch(path, data: data),
        method: 'PATCH',
        path: path,
        data: data,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _executeWithFallback(
        () => _dio.delete(path),
        method: 'DELETE',
        path: path,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<dynamic>> _executeWithFallback(
    Future<Response<dynamic>> Function() request, {
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await request();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final fallback = await _findReachableUrl();
        if (fallback != null && fallback != _dio.options.baseUrl) {
          updateBaseUrl(fallback);
          return await _dio.request(
            path,
            data: data,
            queryParameters: queryParameters,
            options: Options(method: method),
          );
        }
      }
      rethrow;
    }
  }

  Future<String?> _findReachableUrl() async {
    for (final candidate in AppConfig.candidateUrls) {
      if (candidate == _dio.options.baseUrl) continue;
      try {
        final probeDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 1),
            receiveTimeout: const Duration(seconds: 1),
          ),
        );
        final res = await probeDio.get(
          '$candidate/auth/login',
          options: Options(validateStatus: (s) => s != null && s < 500),
        );
        if (res.statusCode == 405 || res.statusCode == 200) {
          return candidate;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Map<String, dynamic> _processResponse(Response response) {
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {'data': response.data};
  }

  Exception _handleDioError(DioException error) {
    final response = error.response;
    if (response != null && response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      final message = data['message'] as String? ?? 'An error occurred';
      return ServerException(message, response.statusCode, data);
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ServerException(
        'Unable to reach garage server (${_dio.options.baseUrl}).\n'
        'Check that Laragon Apache or "php artisan serve" is running.',
        0,
      );
    }

    return ServerException(error.message ?? 'Unknown network failure', 500);
  }
}
