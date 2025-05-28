import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraphQLCacheInterceptor extends Interceptor {
  final Duration maxStale;
  final FlutterSecureStorage _storage;
  final _streamControllers = <String, StreamController<Response>>{};
  Timer? _cleanupTimer;

  GraphQLCacheInterceptor({
    FlutterSecureStorage? storage,
    this.maxStale = const Duration(hours: 4),
  }) : _storage = storage ?? const FlutterSecureStorage() {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanExpiredCache();
    });
  }

  String _getCacheKey(RequestOptions options) {
    return base64Encode(
        utf8.encode('${options.uri}_${options.data.toString()}'));
  }

  Future<void> _cleanExpiredCache() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final allItems = await _storage.readAll();

      for (var entry in allItems.entries) {
        if (entry.key.endsWith('_timestamp')) {
          final timestamp = int.tryParse(entry.value);
          if (timestamp != null && now - timestamp > maxStale.inMilliseconds) {
            // Remove expired cache entry
            final cacheKey = entry.key.replaceAll('_timestamp', '');
            await _storage.delete(key: cacheKey);
            await _storage.delete(key: entry.key);

            // Close and remove associated stream controller
            _streamControllers[cacheKey]?.close();
            _streamControllers.remove(cacheKey);
          }
        }
      }
    } catch (e) {
      debugPrint('Cache cleanup error: $e');
    }
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = _getCacheKey(options);

    try {
      final cachedData = await _storage.read(key: cacheKey);
      final timestampStr = await _storage.read(key: '${cacheKey}_timestamp');

      if (cachedData != null && timestampStr != null) {
        final cacheTimestamp = int.parse(timestampStr);
        final now = DateTime.now().millisecondsSinceEpoch;

        if (now - cacheTimestamp <= maxStale.inMilliseconds) {
          // Return cached data immediately
          final cachedResponse = Response(
            requestOptions: options,
            data: json.decode(cachedData),
            statusCode: 200,
          );

          // Create stream controller if doesn't exist
          _streamControllers[cacheKey] ??=
              StreamController<Response>.broadcast();

          // Send cached response to stream
          _streamControllers[cacheKey]?.add(cachedResponse);

          // Continue with the request in background
          handler.next(options);
          return;
        } else {
          // Remove expired cache
          await _storage.delete(key: cacheKey);
          await _storage.delete(key: '${cacheKey}_timestamp');
        }
      }
    } catch (e) {
      debugPrint('Cache read error: $e');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final cacheKey = _getCacheKey(response.requestOptions);
    final responseData = json.encode(response.data);

    try {
      // Get cached data
      final cachedData = await _storage.read(key: cacheKey);

      // If data is different from cache, update it
      if (cachedData != responseData) {
        await _storage.write(key: cacheKey, value: responseData);
        await _storage.write(
          key: '${cacheKey}_timestamp',
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // Notify listeners about the new data
        _streamControllers[cacheKey]?.add(response);
      }
    } catch (e) {
      debugPrint('Cache write error: $e');
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }

  Stream<Response>? getStreamForRequest(RequestOptions options) {
    final cacheKey = _getCacheKey(options);
    return _streamControllers[cacheKey]?.stream;
  }

  Future<void> clearCache() async {
    try {
      await _storage.deleteAll();
      for (var controller in _streamControllers.values) {
        controller.close();
      }
      _streamControllers.clear();
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    for (var controller in _streamControllers.values) {
      controller.close();
    }
    _streamControllers.clear();
  }
}
