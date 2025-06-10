import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/cache/shared_prefs.dart';
import 'package:mars_scanner/helpers/custom_snackbar.dart';
import 'package:mars_scanner/modules/home/screens/simple_login_screen.dart';
import 'package:mars_scanner/services/keys/api_keys.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_expiry_manager.dart';

class GraphQLService {
  late final CacheOptions cacheOptions;
  int _retryCount = 0;
  static final int _maxRetries = 2;
  static const Duration _retryInterval = Duration(seconds: 1);
  final _tokenManager = TokenExpiryManager();
  static final Map<String, CancelToken> _activeTokens = {};

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiKeys.graphQLApiUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 50),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;

  // Separate Dio instance for retries without interceptors
  static final Dio _retryDio = Dio(
    BaseOptions(
      baseUrl: ApiKeys.graphQLApiUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get retryDio => _retryDio;

  GraphQLService() {
    if (!kReleaseMode) {
      // Only disable certificate verification in debug mode
      (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    // Add logging interceptor in debug mode
    if (!kReleaseMode) {
      _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!_tokenManager.isTokenValid && !options.path.contains('public')) {
          // Wait for token to be valid before proceeding with authenticated requests
          await _tokenManager.waitForTokenRefresh();
        }

        final token = await _tokenManager.getApiToken();
        prints('GraphQL Request Token: $token');
        debugPrint('GraphQL Request URL: ${options.uri}');
        debugPrint('GraphQL Request Headers: ${options.headers}');

        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        if ((response.statusCode == 401 || response.statusCode == 403) &&
            _retryCount < _maxRetries) {
          _retryCount++;
          debugPrint(
              'Retrying request attempt $_retryCount after ${_retryInterval.inSeconds}s delay');

          // Wait for any ongoing token refresh
          await _tokenManager.waitForTokenRefresh();

          // Get fresh token
          final token = await _tokenManager.getApiToken();
          if (token.isEmpty) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: 'Failed to get valid token after refresh',
              ),
            );
          }

          try {
            final updatedHeaders =
                Map<String, dynamic>.from(response.requestOptions.headers)
                  ..['Authorization'] = 'Bearer $token';

            final retryResponse = await _retryDio.fetch(
              response.requestOptions.copyWith(headers: updatedHeaders),
            );
            _retryCount = 0; // Reset counter on successful retry
            return handler.resolve(retryResponse);
          } catch (e) {
            debugPrint('Retry attempt $_retryCount failed: $e');
            return handler.next(response);
          }
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        if ((error.response?.statusCode == 401 ||
                error.response?.statusCode == 403 ||
                error.response?.statusCode == 500 ||
                error.type == DioExceptionType.connectionTimeout ||
                error.type == DioExceptionType.receiveTimeout ||
                error.type == DioExceptionType.sendTimeout ||
                error.type == DioExceptionType.connectionError ||
                error.type == DioExceptionType.badCertificate ||
                error.type == DioExceptionType.badResponse) &&
            _retryCount < _maxRetries) {
          _retryCount++;
          debugPrint(
              'Retrying failed request attempt $_retryCount after ${_retryInterval.inSeconds}s delay');

          // Handle 403 error by refreshing token
          if (error.response?.statusCode == 403) {
            try {
              await Future.delayed(const Duration(milliseconds: 500));

              final newToken = await _tokenManager.getApiToken();
              final updatedHeaders =
                  Map<String, dynamic>.from(error.requestOptions.headers)
                    ..['Authorization'] = 'Bearer $newToken';

              final retryResponse = await _retryDio.fetch(
                error.requestOptions.copyWith(
                  headers: updatedHeaders,
                ),
              );
              _retryCount = 0;
              return handler.resolve(retryResponse);
            } catch (e) {
              debugPrint('Error refreshing token: $e');
              return handler.next(error);
            }
          }

          await Future.delayed(_retryInterval);
          // Retry the failed request using retryDio
          try {
            final token = await _tokenManager.getApiToken();
            final updatedHeaders =
                Map<String, dynamic>.from(error.requestOptions.headers)
                  ..['Authorization'] = 'Bearer $token';

            final retryResponse = await _retryDio.fetch(
              error.requestOptions.copyWith(
                headers: updatedHeaders,
              ),
            );
            _retryCount = 0; // Reset counter on successful retry
            return handler.resolve(retryResponse);
          } catch (e) {
            debugPrint('Retry attempt $_retryCount failed: $e');
            return handler.next(error);
          }
        }
        debugPrint('Retry count: $_retryCount, max retries: $_maxRetries');
        if (_retryCount >= _maxRetries) {
          debugPrint('Maximum retries reached');
          //  if (Platform.isAndroid) {
          _handleSessionExpired();
          //  }
        }
        _retryCount = 0; // Reset counter on error
        return handler.next(error);
      },
    ));
    // Set up cache options
  }

  Future<void> _handleSessionExpired() async {
    await LocalStorage.clearLocalData();
    showCustomSnackbar(
        'Session Expired', 'Your session has timed out. Please log in again.');
    Get.offAll(
      () => SimpleLoginScreen(),
    );
  }

  // Method to perform a GraphQL mutation (not cached by default)
  Future<Map<String, dynamic>> performMutation(
      String mutation, Map<String, dynamic>? variables, String userAgent,
      [CancelToken? cancelToken]) async {
    prints("Inside performMutation\n");
    prints(" 161 mutation : $mutation");
    prints("variables : $variables");
    prints("userAgent : $userAgent\n");

    final token = cancelToken ?? CancelToken();
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    _activeTokens[requestId] = token;
    // POST request for mutations, usually not cached
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
        cancelToken: token,
      );
      if (response.statusCode == 200 && response.data != null) {
        _activeTokens.remove(requestId);
        // Enforce type casting for type safety
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
      _activeTokens.remove(requestId);
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Don't rethrow cancelled requests
        return {};
      }
      throw Exception('Failed to perform query: $e');
    } finally {
      _activeTokens.remove(requestId);
    }
  }

  // Method to perform a cached GraphQL query
  performQueryWithCache(String query, String userAgent,
      {bool forceRefresh = false}) async {
    debugPrint("Inside performQueryWithCache");
    // POST request for query with cache
    try {
      // POST request for query with cache
      final response = await _dio.post('', // GraphQL API endpoint
          data: {
            'query': query,
            'operationName': userAgent,
          },
          options: Options(
            headers: {
              'User-Agent': userAgent,
            },
          ));

      if (response.statusCode == 200 && response.data != null) {
        // Enforce type casting for type safety
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
      debugPrint("Error during query: $e");
      throw Exception('Failed to perform query: $e');
    }
  }

  // Method to perform a cached GraphQL query with variables
  Future<Map<String, dynamic>> performVariableQueryWithCache(
      String query, String userAgent, Map<String, dynamic> variables,
      {bool forceRefresh = false}) async {
    debugPrint("Inside performVariableQueryWithCache");
    // POST request for query with variables and cache
    final response = await _dio.post('', // GraphQL API endpoint
        data: {
          'query': query,
          'variables': variables,
          'operationName': userAgent,
        },
        options: Options(
          headers: {
            'User-Agent': userAgent,
          },
        ));
    if (response.statusCode == 200 && response.data != null) {
      if (response.data.runtimeType == String) {
        return json.decode(response.data);
      }
      return response.data;
    } else {
      throw Exception('Failed to perform query with variables');
    }
  }

  // Method to manually clear cache
  Future<void> clearCache() async {
    debugPrint("Clearing cache...");
    await cacheOptions.store
        ?.clean(); // Clear in-memory cache (or disk cache if using FileCacheStore)
  }

  // Helper method for printing long logs
  void prints(var s1) {
    String s = s1.toString();
    final pattern = RegExp('.{1,800}'); // Split long strings into chunks
    pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
  }

  // Method to cancel all requests
  static Future<void> cancelAllRequests() async {
    debugPrint("351ssd: Canceling all requests...");
    for (final token in _activeTokens.values) {
      if (!token.isCancelled) {
        token.cancel('351ssd: Cancelled by user for graphs');
      }
    }
    _activeTokens.clear();
  }
}
