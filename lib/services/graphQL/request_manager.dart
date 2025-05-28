import 'dart:async';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'graphql_service.dart';

class RequestManager {
  static final RequestManager _instance = RequestManager._internal();
  factory RequestManager() => _instance;

  RequestManager._internal();

  final Map<String, CancelToken> _activeRequests = {};
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};
  final Duration _debounceTime = const Duration(seconds: 2);
  final _dio = GraphQLService.dio;
  final _retryDio = GraphQLService.retryDio;

  // Generate a hash for the request based on query and variables
  String _generateRequestHash(String query, Map<String, dynamic> variables) {
    final content = jsonEncode({
      'query': query,
      'variables': variables,
    });
    return md5.convert(utf8.encode(content)).toString();
  }

  // Get or create a CancelToken for a request
  CancelToken getCancelToken(String requestHash) {
    return _activeRequests.putIfAbsent(requestHash, () => CancelToken());
  }

  // Cancel an active request
  void cancelRequest(String requestHash) {
    final token = _activeRequests[requestHash];
    if (token != null && !token.isCancelled) {
      token.cancel('Request cancelled');
      _activeRequests.remove(requestHash);
    }
  }

  // Cancel all active requests
  void cancelAllRequests() {
    // Cancel all active requests but keep the client usable

    // Also clear our local tracking
    for (final token in _activeRequests.values) {
      if (!token.isCancelled) {
        token.cancel('All requests cancelled');
      }
    }
    _activeRequests.clear();
  }

  // Handle debouncing for similar requests
  Future<Map<String, dynamic>> debounceRequest(
    String query,
    Map<String, dynamic> variables,
    Future<Map<String, dynamic>> Function() requestFunction,
  ) async {
    final requestHash = _generateRequestHash(query, variables);

    // Cancel any existing timer for this request
    _debounceTimers[requestHash]?.cancel();

    // If there's a pending request with the same hash, return its future
    if (_pendingRequests.containsKey(requestHash)) {
      return _pendingRequests[requestHash]!.future;
    }

    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[requestHash] = completer;

    // Set up debounce timer
    _debounceTimers[requestHash] = Timer(_debounceTime, () async {
      try {
        final response = await requestFunction();
        completer.complete(response);
      } catch (e) {
        completer.completeError(e);
      } finally {
        _pendingRequests.remove(requestHash);
        _debounceTimers.remove(requestHash);
      }
    });

    return completer.future;
  }

  // Clean up resources
  void dispose() {
    cancelAllRequests();
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _pendingRequests.clear();
  }

  // Check if a request is already pending
  bool isRequestPending(String query, Map<String, dynamic> variables) {
    final requestHash = _generateRequestHash(query, variables);
    return _pendingRequests.containsKey(requestHash);
  }

  // Get the number of active requests
  int get activeRequestCount => _activeRequests.length;

  // Get the number of pending requests
  int get pendingRequestCount => _pendingRequests.length;
}
