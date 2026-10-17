sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication error']);
}

final class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Not an admin']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}
