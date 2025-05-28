import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mars_scanner/services/keys/api_keys.dart';

class UnAuthGraphQLService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiKeys.graphQLApiUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${ApiKeys.unAuthToken}',
      },
    ),
  );

  Future<Map<String, dynamic>> performMutation(String mutation,
      Map<String, dynamic>? variables, String userAgent) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'query': mutation,
          'variables': variables,
          'operationName': userAgent,
        },
        options: Options(
          headers: {
            'User-Agent': userAgent,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data.runtimeType == String) {
          return json.decode(response.data);
        } else if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception(
              'Unexpected response type: ${response.data.runtimeType}');
        }
      } else {
        throw Exception(
            'Failed to perform query. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to perform query: $e');
    }
  }
}
