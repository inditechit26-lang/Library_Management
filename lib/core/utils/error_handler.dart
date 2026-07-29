import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../exceptions/app_exception.dart';

class ErrorHandler {
  /// Converts raw exceptions to strongly typed [AppException]
  static AppException handle(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return PermissionDeniedException(
            'Access denied. You do not have permission for this resource.',
            error.code,
          );
        case 'not-found':
          return const DocumentMissingException(
            'The requested record was not found.',
          );
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkException(
            'Network unavailable. Operating in offline mode.',
          );
        case 'already-exists':
          return const ValidationException(
            'A record with this identifier already exists.',
          );
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return const AuthException('Invalid email or password.');
        case 'email-already-in-use':
          return const AuthException(
            'An account with this email already exists.',
          );
        case 'too-many-requests':
          return const AuthException(
            'Too many requests. Please wait before trying again.',
          );
        case 'user-disabled':
          return const AuthException(
            'This account has been disabled. Please contact support.',
          );
        case 'invalid-user-token':
        case 'user-token-expired':
        case 'requires-recent-login':
          return const AuthException(
            'Your session has expired. Please sign in again.',
          );
        case 'quota-exceeded':
          return const NetworkException(
            'Server quota exceeded. Please try again later.',
          );
        case 'canceled':
          return const UnknownException('Operation was cancelled.');
        default:
          return UnknownException(
            error.message ?? 'Firebase error: ${error.code}',
            error.code,
            error,
            stackTrace,
          );
      }
    }

    if (error is SocketException || error is TimeoutException) {
      return const NetworkException();
    }

    return UnknownException(
      error?.toString() ?? 'An unexpected error occurred.',
      'UNKNOWN',
      error,
      stackTrace,
    );
  }

  /// Displays standard Material Snackbar for errors
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final appError = handle(error);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                appError.message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Displays standard Material Snackbar for success messages
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

extension ColorExtension on Colors {
  static Color get emerald => const Color(0xFF10B981);
}
