import 'dart:async';

class RequestQueue {
  final List<_QueueItem> _queue = [];
  bool _processing = false;
  static const int _maxQueueSize = 100;
  static const Duration _requestTimeout = Duration(seconds: 30);

  Future<T> enqueue<T>(
    Future<T> Function() request,
    String operationType,
    String queryHash, {
    int priority = 0,
  }) async {
    if (_queue.length >= _maxQueueSize) {
      throw Exception('Request queue is full');
    }

    final completer = Completer<T>();
    final item = _QueueItem(
      request: request,
      completer: completer,
      priority: priority,
      operationType: operationType,
      queryHash: queryHash,
    );

    _addToQueue(item);
    _processQueue();

    try {
      return await completer.future.timeout(_requestTimeout);
    } catch (e) {
      if (e is TimeoutException) {
        _queue.remove(item);
        throw TimeoutException('Request timed out');
      }
      rethrow;
    }
  }

  void _addToQueue(_QueueItem item) {
    if (_queue.isEmpty) {
      _queue.add(item);
      return;
    }

    // Find insertion point based on priority
    final insertIndex =
        _queue.indexWhere((queueItem) => item.priority > queueItem.priority);
    if (insertIndex == -1) {
      _queue.add(item); // Add to end if lowest priority
    } else {
      _queue.insert(insertIndex, item);
    }
  }

  Future<void> _processQueue() async {
    if (_processing || _queue.isEmpty) return;

    _processing = true;
    while (_queue.isNotEmpty) {
      final item = _queue.first;
      try {
        final result = await item.request();
        if (!item.completer.isCompleted) {
          item.completer.complete(result);
        }
      } catch (e, stackTrace) {
        if (!item.completer.isCompleted) {
          item.completer.completeError(e, stackTrace);
        }
      } finally {
        _queue.removeAt(0);
      }
    }
    _processing = false;
  }

  void dispose() {
    for (final item in _queue) {
      if (!item.completer.isCompleted) {
        item.completer.completeError(
          StateError('Request queue disposed'),
        );
      }
    }
    _queue.clear();
  }
}

class _QueueItem<T> {
  final Future<T> Function() request;
  final Completer<T> completer;
  final int priority;
  final String operationType;
  final String queryHash;

  _QueueItem({
    required this.request,
    required this.completer,
    required this.priority,
    required this.operationType,
    required this.queryHash,
  });
}
