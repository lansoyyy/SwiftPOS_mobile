import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_colors.dart';

/// Error Handler - Centralized error handling and user feedback
class ErrorHandler {
  /// Show error toast
  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Show success toast
  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Show info toast
  static void showInfoToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Show warning toast
  static void showWarningToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onRetry,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontFamily: 'Urbanist')),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  static Future<void> showSuccessDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontFamily: 'Urbanist')),
        actions: [
          if (onConfirm != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool?> showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(message, style: const TextStyle(fontFamily: 'Urbanist')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive
                  ? AppColors.error
                  : AppColors.primary,
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  static Future<void> showLoadingDialog(
    BuildContext context, {
    String message = 'Please wait...',
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Urbanist'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle generic error
  static void handleError(dynamic error, {String? customMessage}) {
    String message = customMessage ?? 'An error occurred';

    if (error is AppException) {
      message = error.message;
    } else if (error.toString().contains('Network')) {
      message = 'Network error. Please check your connection.';
    } else if (error.toString().contains('Database')) {
      message = 'Database error. Please try again.';
    } else if (error.toString().contains('Permission')) {
      message = 'Permission denied. Please grant required permissions.';
    }

    showErrorToast(message);
  }

  /// Handle error with dialog
  static Future<void> handleErrorWithDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    String? customMessage,
    VoidCallback? onRetry,
  }) async {
    String message = customMessage ?? 'An error occurred';

    if (error is AppException) {
      message = error.message;
      title ??= error.title ?? 'Error';
    } else if (error.toString().contains('Network')) {
      message = 'Network error. Please check your connection.';
    } else if (error.toString().contains('Database')) {
      message = 'Database error. Please try again.';
    } else if (error.toString().contains('Permission')) {
      message = 'Permission denied. Please grant required permissions.';
    }

    await showErrorDialog(context, title ?? 'Error', message, onRetry: onRetry);
  }
}

/// Base Application Exception
class AppException implements Exception {
  final String message;
  final String? title;
  final int? code;

  AppException(this.message, {this.title, this.code});

  @override
  String toString() => message;
}

/// Database Exception
class DatabaseException extends AppException {
  DatabaseException(String message) : super(message, title: 'Database Error');
}

/// Network Exception
class NetworkException extends AppException {
  NetworkException(String message) : super(message, title: 'Network Error');
}

/// Validation Exception
class ValidationException extends AppException {
  ValidationException(String message)
    : super(message, title: 'Validation Error');
}

/// Permission Exception
class PermissionException extends AppException {
  PermissionException(String message)
    : super(message, title: 'Permission Error');
}

/// Not Found Exception
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, title: 'Not Found');
}

/// Unauthorized Exception
class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, title: 'Unauthorized');
}

/// Server Exception
class ServerException extends AppException {
  ServerException(String message, {int? code})
    : super(message, title: 'Server Error', code: code);
}

/// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final String? error;

  Result._(this.data, this.error);

  factory Result.success(T data) => Result._(data, null);
  factory Result.failure(String error) => Result._(null, error);

  bool get isSuccess => error == null;
  bool get isFailure => error != null;

  T get valueOrThrow {
    if (isFailure) {
      throw AppException(error!);
    }
    return data!;
  }

  T? get valueOrNull => data;
}

/// Safe execution wrapper
class SafeExecutor {
  /// Execute a function safely and return a Result
  static Future<Result<T>> execute<T>(Future<T> Function() fn) async {
    try {
      final result = await fn();
      return Result<T>.success(result);
    } catch (e) {
      return Result<T>.failure(e.toString());
    }
  }

  /// Execute a function synchronously and return a Result
  static Result<T> executeSync<T>(T Function() fn) {
    try {
      final result = fn();
      return Result<T>.success(result);
    } catch (e) {
      return Result<T>.failure(e.toString());
    }
  }
}
