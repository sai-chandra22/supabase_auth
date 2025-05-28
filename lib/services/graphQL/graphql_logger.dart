import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class GraphQLLogger {
  static final GraphQLLogger _instance = GraphQLLogger._internal();
  factory GraphQLLogger() => _instance;

  GraphQLLogger._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  // Performance metrics
  final Map<String, List<int>> _responseTimes = {};
  final Map<String, int> _errorCounts = {};
  final Map<String, int> _retryCounts = {};

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'version': iosInfo.systemVersion,
          'device': iosInfo.model,
        };
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'version': androidInfo.version.release,
          'device': androidInfo.model,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
    return {'platform': 'unknown'};
  }

  Future<String> _getNetworkStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.toString();
    } catch (e) {
      debugPrint('Error getting network status: $e');
      return 'unknown';
    }
  }

  // Log request start
  Future<void> logRequest({
    required String operation,
    required Map<String, dynamic> variables,
    String? queryHash,
  }) async {
    if (!kDebugMode) return;

    final deviceInfo = await _getDeviceInfo();
    final networkStatus = await _getNetworkStatus();

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'variables': _sanitizeVariables(variables),
      'queryHash': queryHash,
      'device': deviceInfo,
      'network': networkStatus,
    };

    debugPrint('GraphQL Request: ${jsonEncode(logData)}');
  }

  // Log response
  void logResponse({
    required String operation,
    required int responseTime,
    Map<String, dynamic>? data,
    dynamic error,
  }) {
    if (!kDebugMode) return;

    // Update metrics
    _responseTimes.putIfAbsent(operation, () => []).add(responseTime);
    if (error != null) {
      _errorCounts[operation] = (_errorCounts[operation] ?? 0) + 1;
    }

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'responseTime': responseTime,
      'success': error == null,
      'error': error?.toString(),
    };

    debugPrint('GraphQL Response: ${jsonEncode(logData)}');
  }

  // Log retry attempt
  void logRetry({
    required String operation,
    required int attempt,
    required String reason,
  }) {
    if (!kDebugMode) return;

    _retryCounts[operation] = (_retryCounts[operation] ?? 0) + 1;

    final logData = {
      'timestamp': DateTime.now().toIso8601String(),
      'operation': operation,
      'attempt': attempt,
      'reason': reason,
    };

    debugPrint('GraphQL Retry: ${jsonEncode(logData)}');
  }

  // Get performance metrics
  Map<String, dynamic> getMetrics() {
    final metrics = {
      'responseTimes': <String, double>{},
      'errorRates': <String, double>{},
      'retryRates': <String, double>{},
    };

    _responseTimes.forEach((operation, times) {
      if (times.isNotEmpty) {
        final avg = times.reduce((a, b) => a + b) / times.length;
        metrics['responseTimes']?[operation] = avg;
      }
    });

    _errorCounts.forEach((operation, count) {
      final total = _responseTimes[operation]?.length ?? 0;
      if (total > 0) {
        metrics['errorRates']?[operation] = count / total;
      }
    });

    _retryCounts.forEach((operation, count) {
      final total = _responseTimes[operation]?.length ?? 0;
      if (total > 0) {
        metrics['retryRates']?[operation] = count / total;
      }
    });

    return metrics;
  }

  // Sanitize sensitive data from variables
  Map<String, dynamic> _sanitizeVariables(Map<String, dynamic> variables) {
    final sanitized = Map<String, dynamic>.from(variables);
    final sensitiveKeys = ['password', 'token', 'auth', 'key', 'secret'];

    void sanitizeMap(Map<String, dynamic> map) {
      map.forEach((key, value) {
        if (sensitiveKeys.any((k) => key.toLowerCase().contains(k))) {
          map[key] = '***';
        } else if (value is Map<String, dynamic>) {
          sanitizeMap(value);
        }
      });
    }

    sanitizeMap(sanitized);
    return sanitized;
  }
}
