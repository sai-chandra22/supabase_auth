import 'package:dio/dio.dart';

String dioExceptionMessage(DioExceptionType type) {
  switch (type) {
    case DioExceptionType.connectionTimeout:
      return 'Connection timeout, Please try again';
    case DioExceptionType.sendTimeout:
      return 'Send timeout, Please try again';
    case DioExceptionType.receiveTimeout:
      return 'Receive timeout, Please try again';
    case DioExceptionType.badCertificate:
      return 'Bad certificate, Please try again';
    case DioExceptionType.badResponse:
      return 'Session expired, Please login again';
    case DioExceptionType.cancel:
      return 'Request cancelled';
    case DioExceptionType.unknown:
      return 'Unknown error, Please try again';
    case DioExceptionType.connectionError:
      return 'No Network, Please check your internet connection';
  }
}
