import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      debugPrint('907ssd User ID set to: $userId');
    } catch (e) {
      debugPrint('907ssd Error setting user ID: $e');
    }
  }

  // Screen tracking
  static Future<void> screenView({
    required String screenName,
    String? screenClass,
  }) async {
    // final Map<String, Object> parameters = {
    //   'firebase_screen': screenName,
    // };

    // if (screenClass != null) {
    //   parameters['firebase_screen_class'] = screenClass;
    // }
    try {
      await _analytics.setCurrentScreen(
        screenName: screenName,
        screenClassOverride: screenClass ?? screenName,
      );
      // await _analytics.logEvent(
      //   name: 'screen_view',
      //   parameters: parameters,
      // );
      debugPrint('907ssd Screen view logged: $screenName');
    } catch (e) {
      debugPrint('907ssd Error logging screen view: $e');
    }
  }

  // Artist search tracking
  static Future<void> searchArtist({
    required String artistId,
    required String artistName,
    String? ticker,
  }) async {
    final Map<String, Object> parameters = {
      'artist_id': artistId,
      'artist_name': artistName,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (ticker != null) {
      parameters['ticker'] = ticker;
    }

    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _analytics.logEvent(
        name: 'search_artist',
        parameters: parameters,
      );
      debugPrint('907ssd Artist search logged: $artistId, $artistName');
    } catch (e) {
      debugPrint('907ssd Error logging artist search: $e');
    }
  }

  // Authentication events
  static Future<void> signUp({
    required String provider,
    bool? isFromScn,
    String? scnNumber,
    String? userId,
    String? userName,
  }) async {
    final Map<String, Object> parameters = {
      'provider': provider,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (isFromScn != null) {
      parameters['is_from_scn'] = isFromScn;
    }

    if (scnNumber != null) {
      parameters['scn_number'] = scnNumber;
    }

    if (userId != null) {
      parameters['user_id'] = userId;
    }

    if (userName != null) {
      parameters['user_name'] = userName;
    }

    try {
      await _analytics.logEvent(
        name: 'sign_up',
        parameters: parameters,
      );
      debugPrint('907ssd Sign up logged: $provider, $userName, $userId');
    } catch (e) {
      debugPrint('907ssd Error logging sign up: $e');
    }
  }

  static Future<void> signIn({
    required String provider,
    String? userName,
    String? userId,
  }) async {
    final Map<String, Object> parameters = {
      'provider': provider,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (userName != null) {
      parameters['user_name'] = userName;
    }

    if (userId != null) {
      parameters['user_id'] = userId;
    }

    try {
      await _analytics.logEvent(
        name: 'sign_in',
        parameters: parameters,
      );
      debugPrint('907ssd Sign in logged: $provider, $userName, $userId');
    } catch (e) {
      debugPrint('907ssd Error logging sign in: $e');
    }
  }

  static Future<void> accountDeletion(String? userId, String? userName) async {
    final Map<String, Object> parameters = {
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (userId != null) {
      parameters['user_id'] = userId;
    }

    if (userName != null) {
      parameters['user_name'] = userName;
    }

    try {
      await _analytics.logEvent(
        name: 'account_deletion',
        parameters: parameters,
      );
      debugPrint('907ssd Account deletion logged: $userId, $userName');
    } catch (e) {
      debugPrint('907ssd Error logging account deletion: $e');
    }
  }

  static Future<void> userLogout(String? userId, String? userName) async {
    final Map<String, Object> parameters = {
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (userId != null) {
      parameters['user_id'] = userId;
    }

    if (userName != null) {
      parameters['user_name'] = userName;
    }

    try {
      await _analytics.logEvent(
        name: 'user_logout',
        parameters: parameters,
      );
      debugPrint('907ssd User logout logged: $userId, $userName');
    } catch (e) {
      debugPrint('907ssd Error logging user logout: $e');
    }
  }
}
