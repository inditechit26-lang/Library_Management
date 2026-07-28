/// Enterprise Exception classes for standardizing errors across the application.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Network connection failure. Please check your internet connection.', String? code])
      : super(message, code: code ?? 'NETWORK_ERROR');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String message = 'You do not have permission to perform this action.', String? code])
      : super(message, code: code ?? 'PERMISSION_DENIED');
}

class DocumentMissingException extends AppException {
  const DocumentMissingException([String message = 'Requested record was not found.', String? code])
      : super(message, code: code ?? 'NOT_FOUND');
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError, super.stackTrace});
}

class UploadException extends AppException {
  const UploadException([String message = 'File upload failed. Please try again.', String? code])
      : super(message, code: code ?? 'UPLOAD_FAILED');
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'Operation timed out. Please try again.', String? code])
      : super(message, code: code ?? 'TIMEOUT');
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

class UnknownException extends AppException {
  const UnknownException([String message = 'An unexpected error occurred.', String? code, dynamic originalError, StackTrace? stackTrace])
      : super(message, code: code ?? 'UNKNOWN', originalError: originalError, stackTrace: stackTrace);
}
