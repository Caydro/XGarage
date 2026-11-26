import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection error. Please check your internet.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Session expired or unauthenticated.', super.statusCode = 401]);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(super.message, [this.fieldErrors, super.statusCode = 422]);

  @override
  List<Object?> get props => [message, statusCode, fieldErrors];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Storage error occurred.']);
}
