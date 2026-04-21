import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_error.dart';

class ErrorHandler {
  // Firebase Auth errors
  static AppError handleFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppError(
          type: ErrorType.notFound,
          message: 'No user found with this email.',
        );
      case 'wrong-password':
        return AppError(
          type: ErrorType.unauthorized,
          message: 'Wrong password. Please try again.',
        );
      case 'email-already-in-use':
        return AppError(
          type: ErrorType.server,
          message: 'Email is already in use.',
        );
      case 'invalid-email':
        return AppError(
          type: ErrorType.unknown,
          message: 'Invalid email address.',
        );
      case 'weak-password':
        return AppError(
          type: ErrorType.unknown,
          message: 'Password is too weak.',
        );
      case 'network-request-failed':
        return AppError(
          type: ErrorType.network,
          message: 'No internet connection.',
        );
      case 'too-many-requests':
        return AppError(
          type: ErrorType.server,
          message: 'Too many attempts. Try again later.',
        );
      case 'user-disabled':
        return AppError(
          type: ErrorType.unauthorized,
          message: 'This account has been disabled.',
        );
      case 'invalid-credential':
        return AppError(
          type: ErrorType.unauthorized,
          message: 'Invalid email or password.',
        );
      default:
        return AppError(
          type: ErrorType.unknown,
          message: e.message ?? 'Something went wrong.',
        );
    }
  }

  // Dio/API errors (future use)
  static AppError handle(dynamic error) {
    if (error is FirebaseAuthException) {
      return handleFirebase(error);
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return AppError(
            type: ErrorType.timeout,
            message: 'Request timeout. Try again.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          final message = _extractMessage(data);

          if (statusCode == 401) {
            return AppError(
              type: ErrorType.unauthorized,
              message: message.isNotEmpty
                  ? message
                  : 'Invalid credentials.',
            );
          }
          if (statusCode == 403) {
            return AppError(
              type: ErrorType.unauthorized,
              message: message.isNotEmpty
                  ? message
                  : 'You don\'t have permission.',
            );
          }
          if (statusCode == 404) {
            return AppError(
              type: ErrorType.notFound,
              message: message.isNotEmpty
                  ? message
                  : 'Resource not found.',
            );
          }
          return AppError(
            type: ErrorType.server,
            message: message.isNotEmpty
                ? message
                : 'Server error (${statusCode ?? "unknown"})',
          );
        case DioExceptionType.connectionError:
          return AppError(
            type: ErrorType.network,
            message: 'No internet connection.',
          );
        default:
          return AppError(
            type: ErrorType.unknown,
            message: 'Unexpected error occurred.',
          );
      }
    }

    // General error
    String message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }

    return AppError(
      type: ErrorType.unknown,
      message: message,
    );
  }

  // Extract message from response data
  static String _extractMessage(dynamic data) {
    if (data == null) return '';

    if (data is Map) {
      if (data['error_description'] != null) {
        return data['error_description'].toString();
      }
      if (data['error'] != null) {
        final error = data['error'];
        if (error is Map) {
          return error['details']?.toString() ??
              error['message']?.toString() ??
              '';
        }
        if (error is String) return error;
      }
      return data['message']?.toString() ?? '';
    }

    if (data is String) return data;

    return '';
  }
}