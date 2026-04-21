import 'package:flutter/material.dart';

enum ErrorType {
  network,
  timeout,
  server,
  unauthorized,
  notFound,
  unknown,
}

class AppError {
  final ErrorType type;
  final String message;

  AppError({
    required this.type,
    required this.message,
  });

  IconData get icon {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.unauthorized:
        return Icons.lock_outline;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.notFound:
        return Icons.search_off;
      default:
        return Icons.error_outline;
    }
  }

  Color get color {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.timeout:
        return Colors.amber;
      case ErrorType.unauthorized:
        return Colors.red;
      case ErrorType.server:
        return Colors.redAccent;
      case ErrorType.notFound:
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  String get title {
    switch (type) {
      case ErrorType.network:
        return 'No Internet Connection';
      case ErrorType.timeout:
        return 'Request Timeout';
      case ErrorType.unauthorized:
        return 'Unauthorized';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.notFound:
        return 'Not Found';
      default:
        return 'Something Went Wrong';
    }
  }
}