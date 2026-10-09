import "dart:io";

import "package:dio/dio.dart" hide Headers;
import "package:ustachi/core/api/error/failures.dart";
import "package:ustachi/core/api/error/validation_error.dart";
import "package:ustachi/core/utils/constants/error_messages.dart";

final class DioErrorHandler implements Exception {
  DioErrorHandler.withDioError({required DioException error}) {
    _handleError(error);
  }

  DioErrorHandler.withError({required String message, int? code}) {
    _errorMessage = message;
    _errorCode = code;
  }

  int? _errorCode;
  String _errorMessage = "";
  ValidationError? _validationError;

  int get errorCode => _errorCode ?? 0;
  String get message => _errorMessage;
  ValidationError? get validationError => _validationError;
  void _handleError(DioException error) {
    final serverMessage = _extractMessage(error.response?.data);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _errorMessage = ErrorMessages.connectionTimeout;
        return;

      case DioExceptionType.cancel:
        _errorMessage = ErrorMessages.canceled;
        return;

      case DioExceptionType.unknown:

        if (error.error is SocketException) {
          _errorMessage = ErrorMessages.noInternetConnection;
          return;
        }
        _errorMessage = ErrorMessages.somethingWrong;
        return;

      case DioExceptionType.badCertificate:
        _errorMessage = ErrorMessages.badCertificate;
        return;

      case DioExceptionType.connectionError:
        _errorMessage = ErrorMessages.connectionError;
        return;

      case DioExceptionType.badResponse:

        break;

      default:

        _errorMessage = ErrorMessages.somethingWrong;
        return;
    }

    _errorCode = error.response?.statusCode ?? 500;
    switch (_errorCode) {
      case 500:
        _errorMessage = serverMessage ?? ErrorMessages.serverError;
        return;
      case 502:
        _errorMessage = serverMessage ?? ErrorMessages.serverDown;
        return;
      case 404:
        _errorMessage = serverMessage ?? ErrorMessages.notFound;
        return;
      case 413:
        _errorMessage = serverMessage ?? ErrorMessages.requestEntityTooLarge;
        return;
      case 400:
      case 429:
        _errorMessage = serverMessage ?? ErrorMessages.somethingWrong;
        return;
      case 401:
      case 403:
        final data = error.response?.data;

        if (data is Map<String, dynamic>) {
          final errors = data['errors'];
          if (errors is List && errors.isNotEmpty) {
            final firstError = errors.first;
            if (firstError is Map<String, dynamic>) {
              _errorMessage = firstError['detail'].toString();
              return;
            }
          }
        }

        _errorMessage = serverMessage ?? ErrorMessages.permissionDenied;
        return;
      case 422:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          try {
            _validationError = ValidationError.fromJson(data);
            _errorMessage = _validationError?.allFieldMessages ??
                serverMessage ??
                ErrorMessages.validationError;
          } catch (_) {
            _errorMessage = serverMessage ?? ErrorMessages.validationError;
          }
        }
        return;
      default:

        if (error.response?.data is Map<String, dynamic>) {
          try {
            _validationError = ValidationError.fromJson(error.response?.data);
            _errorMessage = _validationError?.allFieldMessages ??
                serverMessage ??
                ErrorMessages.somethingWrong;
            return;
          } catch (_) {}
        }
        _errorMessage = serverMessage ?? ErrorMessages.somethingWrong;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final direct = data['error'] ?? data['detail'] ?? data['message'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }

    for (final value in data.values) {
      if (value is List && value.isNotEmpty) {
        final first = value.first?.toString();
        if (first != null && first.trim().isNotEmpty) {
          return first.trim();
        }
      }

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }
}

extension ServerErrorExtension on DioErrorHandler {
  bool get isTokenExpired => errorCode == 401;

  ServerFailure get failure =>
      ServerFailure(message, errorCode, validationError: validationError);
}
