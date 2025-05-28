import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];

  NetworkManager._internal() {
    _initConnectivity();
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      _updateConnectionStatus(result);
      debugPrint('NetworkManager: Connectivity changed to: $result');
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(result);
    } on PlatformException catch (e) {
      debugPrint('NetworkManager: Could not check connectivity status: $e');
      isConnected.value = false;
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    _connectionStatus = results;

    // Update isConnected based on connection results
    final hasConnection = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);

    if (isConnected.value != hasConnection) {
      isConnected.value = hasConnection;
      debugPrint(
          'NetworkManager: 49ssd Connection status updated to: $hasConnection');
    }
  }

  // Public method to force a connection check
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
      return isConnected.value;
    } catch (e) {
      debugPrint('NetworkManager: Check connectivity error: $e');
      return false;
    }
  }

  List<ConnectivityResult> get currentStatus => _connectionStatus;

  void dispose() {
    _connectivitySubscription.cancel();
    isConnected.dispose();
  }
}
