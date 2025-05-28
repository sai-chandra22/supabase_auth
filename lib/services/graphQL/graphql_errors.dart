import 'package:dio/dio.dart';

/// Base class for all GraphQL related errors
class GraphQLBaseError implements Exception {
  final String message;
  final dynamic originalError;
  final Map<String, dynamic>? context;

  GraphQLBaseError(this.message, {this.originalError, this.context});

  @override
  String toString() => 'GraphQLBaseError: $message';
}

/// Network related errors (timeout, no connection)
class GraphQLNetworkError extends GraphQLBaseError {
  GraphQLNetworkError(super.message, {super.originalError, super.context});

  factory GraphQLNetworkError.fromDioError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection';
        break;
      default:
        message = 'Network error occurred';
    }
    return GraphQLNetworkError(
      message,
      originalError: error,
      context: {
        'path': error.requestOptions.path,
        'method': error.requestOptions.method,
      },
    );
  }
}

/// Server errors (500, etc)
class GraphQLServerError extends GraphQLBaseError {
  final int statusCode;

  GraphQLServerError(super.message, this.statusCode,
      {super.originalError, super.context});

  factory GraphQLServerError.fromDioError(DioException error) {
    return GraphQLServerError(
      'Server error occurred',
      error.response?.statusCode ?? 500,
      originalError: error,
      context: {
        'path': error.requestOptions.path,
        'method': error.requestOptions.method,
        'statusCode': error.response?.statusCode,
        'data': error.response?.data,
      },
    );
  }
}

/// Malformed request errors
class GraphQLRequestError extends GraphQLBaseError {
  GraphQLRequestError(super.message, {super.originalError, super.context});
}

/// Unexpected response format errors
class GraphQLResponseError extends GraphQLBaseError {
  GraphQLResponseError(super.message, {super.originalError, super.context});
}
