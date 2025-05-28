import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mars_scanner/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../modules/onboarding/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class LocalStorage {
  static const String _graphQLApiTokenKey = 'marsGraphQLApiTokenSCANNER';
  static const String _refreshTokenKey = 'marsRefreshTokenSCANNER';
  static const String _currentSessionRefreshTokenKey =
      'marsCurrentSessionRefreshTokenSCANNER';
  static const String _expiresInKey = 'marsExpiresInSCANNER';
  static const String _expiresAtKey = 'marsExpiresAtSCANNER';
  static const String _userDataKey = 'marsUserDataKeySCANNER';
  static const String _saveSession = 'marsSaveSessionSCANNER';
  static const String _deepLinkKey = 'pending_deep_link_dataSCANNER';
  static const String _newsDeepLinkKey = 'pending_news_deep_link_dataSCANNER';
  static const String _isFirstTime = 'isFirstTimeSCANNER';
  static const String session = 'spssb5SCANNER';
  static const String _shareEventNotificationKey =
      'shareEventNotificationKeySCANNER';
  static final _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'mars_mobile_prefs_SCANNER',
      preferencesKeyPrefix: 'mars_mobile_SCANNER',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Clear both the GraphQL token and user data from local storage
  static Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _graphQLApiTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _currentSessionRefreshTokenKey);
    await _secureStorage.delete(key: _expiresInKey);
    await _secureStorage.delete(key: _expiresAtKey);
    await prefs.remove(_userDataKey);
  }

  static Future<void> clearPersistentStorageKey() async {
    final storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: false, // Add this line
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    await storage.delete(key: sb.supabasePersistSessionKey);
    debugPrint('733ssd Persistent session key cleared');
  }

  /// Get the GraphQL API token from secure storage
  static Future<String?> getGraphQLApiToken() async {
    return await _secureStorage.read(key: _graphQLApiTokenKey);
  }

  /// Store the GraphQL API token in secure storage
  static Future<void> setGraphQLApiToken(String token) async {
    await _secureStorage.write(key: _graphQLApiTokenKey, value: token);
  }

  /// Store the refresh token in secure storage
  static Future<void> setRefreshToken(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> setCurrentSessionRefreshToken(String refreshToken) async {
    await _secureStorage.write(
        key: _currentSessionRefreshTokenKey, value: refreshToken);
  }

  /// Store the token expiry details in secure storage
  static Future<void> setTokenExpiry(String expiresIn, String expiresAt) async {
    await _secureStorage.write(key: _expiresInKey, value: expiresIn);
    await _secureStorage.write(key: _expiresAtKey, value: expiresAt);
  }

  /// Get the refresh token from secure storage
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  static Future<String?> getCurrentSessionRefreshToken() async {
    return await _secureStorage.read(key: _currentSessionRefreshTokenKey);
  }

  /// Get the token expiry details from secure storage
  static Future<Map<String, String?>> getTokenExpiry() async {
    final expiresIn = await _secureStorage.read(key: _expiresInKey);
    final expiresAt = await _secureStorage.read(key: _expiresAtKey);
    return {
      'expires_in': expiresIn,
      'expires_at': expiresAt,
    };
  }

  static Future<void> setSession(sb.Session session) async {
    final jsonStr = session.toString();
    await _secureStorage.write(key: _saveSession, value: jsonStr);
  }

  static getSession() async {
    final str = await _secureStorage.read(key: _saveSession);
    if (str != null) {
      return str;
    }

    return null;
  }

  static Future<void> clearSecureStorage() async {
    await _secureStorage.delete(key: _graphQLApiTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _expiresInKey);
    await _secureStorage.delete(key: _expiresAtKey);
    // await clearSession();

    debugPrint('733ssd All secure storage data cleared');
  }

  static Future<void> clearIOSKeychain() async {
    try {
      if (Platform.isIOS) {
        await _secureStorage.deleteAll(
          iOptions: IOSOptions(
            synchronizable: true, // Clear synchronizable data as well.
          ),
        );
        debugPrint('733ssd iOS keychain cleared');
      }
    } catch (e) {
      debugPrint('733ssd Error clearing iOS keychain: $e');
    }
  }

  static Future<void> clearSession() async {
    await CustomSecureStorage(persistSessionKey: session).clearSecureStorage();
  }

  /// Get the raw user data (as JSON string) from local storage
  // static Future<String?> _getUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(_userDataKey);
  // }
  // /// Store the user data (as JSON string) in local storage
  // static Future<void> _setUserData(String data) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(_userDataKey, data);
  // }
  /// Retrieve the User model from local storage
  static Future<User?> getUserModel() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userDataKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      } catch (e) {
        debugPrint('Error parsing user model: $e');
        return null;
      }
    }
    return null;
  }

  /// Store the User model in local storage
  static Future<void> setUserModel(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson =
        jsonEncode(user.toJson()); // Convert user model to JSON string
    await prefs.setString(_userDataKey, userJson);
    debugPrint('User model saved to local storage: $userJson');
  }

  /// Store both User model and API token in local storage
  static Future<void> setUserAndToken(User user, String token) async {
    await setGraphQLApiToken(token); // Store token
    await setUserModel(user); // Store user model
  }

  /// Retrieve both User model and API token together
  static Future<Map<String, dynamic>> getUserAndToken() async {
    String? token = await getGraphQLApiToken();
    User? user = await getUserModel();
    return {
      'token': token,
      'user': user,
    };
  }

  /// Check if the access token has expired
  static Future<bool> isAccessTokenExpired() async {
    try {
      final tokenExpiry = await getTokenExpiry();
      final expiresAtStr = tokenExpiry['expires_at'];

      if (expiresAtStr == null) {
        debugPrint('73ssd: No expiry timestamp found');
        return true;
      }

      // Try parsing as seconds first, then milliseconds if that fails
      DateTime expiresAt;
      try {
        int timeStamp = int.parse(expiresAtStr);
        // Check if timestamp is in milliseconds (13 digits) or seconds (10 digits)
        if (timeStamp.toString().length > 10) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(timeStamp);
        } else {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
        }
      } catch (e) {
        debugPrint('73ssd: Failed to parse timestamp: $e');
        return true;
      }

      final now = DateTime.now();
      final diff = expiresAt.difference(now);

      // Format the expiry time
      final components = <String>[];
      if (diff.inDays != 0) components.add('${diff.inDays} day(s)');
      if (diff.inHours.remainder(24) != 0) {
        components.add('${diff.inHours.remainder(24)} hour(s)');
      }
      if (diff.inMinutes.remainder(60) != 0) {
        components.add('${diff.inMinutes.remainder(60)} min(s)');
      }
      if (diff.inSeconds.remainder(60) != 0) {
        components.add('${diff.inSeconds.remainder(60)} sec(s)');
      }

      debugPrint('73ssd: 1 Token expires in: ${components.join(' ')}');

      // Return true if token has expired or will expire in the next 2 minutes
      final twoMinutesFromNow = now.add(const Duration(minutes: 2));
      return twoMinutesFromNow.isAfter(expiresAt);
    } catch (e) {
      debugPrint('73ssd: Error checking token expiry: $e');
      return true;
    }
  }

  /// Get all token related data including expiry details
  static Future<Map<String, String?>> getAllTokenData() async {
    try {
      final token = await getGraphQLApiToken();
      final refreshToken = await getRefreshToken();
      final expiry = await getTokenExpiry();

      return {
        'token': token,
        'refresh_token': refreshToken,
        'expires_in': expiry['expires_in'],
        'expires_at': expiry['expires_at'],
      };
    } catch (e) {
      debugPrint('Error getting token data: $e');
      return {};
    }
  }

  /// Store all token related data at once
  static Future<void> setAllTokenData({
    required String token,
    required String refreshToken,
    required String expiresIn,
    required String expiresAt,
  }) async {
    try {
      await setGraphQLApiToken(token);
      await setRefreshToken(refreshToken);
      await setTokenExpiry(expiresIn, expiresAt);
    } catch (e) {
      debugPrint('Error setting token data: $e');
      rethrow;
    }
  }

  /// Get the token expiry timestamp in seconds
  static Future<double> getExpiresAt() async {
    final tokenExpiry = await getTokenExpiry();
    final expiresAtStr = tokenExpiry['expires_at'];

    if (expiresAtStr == null) {
      return 0;
    }

    try {
      int timeStamp = int.parse(expiresAtStr);
      // Convert to seconds if in milliseconds
      return timeStamp.toString().length > 10
          ? timeStamp / 1000
          : timeStamp.toDouble();
    } catch (e) {
      debugPrint('73ssd: Failed to parse expires_at timestamp: $e');
      return 0;
    }
  }

  static Future<void> setDeepLink(String? deepLink) async {
    final prefs = await SharedPreferences.getInstance();
    if (deepLink == null) {
      await prefs.remove(_deepLinkKey);
    } else {
      await prefs.setString(_deepLinkKey, deepLink);
    }
  }

  static Future<String?> getDeepLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_deepLinkKey);
  }

  static Future<void> setNewsDeepLink(String? deepLink) async {
    debugPrint('73ssd: News deep link Stored');
    try {
      final prefs = await SharedPreferences.getInstance();
      if (deepLink == null) {
        await prefs.remove(_newsDeepLinkKey);
      } else {
        await prefs.setString(_newsDeepLinkKey, deepLink);
      }
      debugPrint('73ssd: News deep link Stored');
    } catch (e) {
      debugPrint('73ssd: Error storing news deep link: $e');
    }
  }

  static Future<String?> setShareEventNotification(
      Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(_shareEventNotificationKey, jsonString);
      debugPrint('733ssd: Share event notification stored: $jsonString');
      return jsonString;
    } catch (e) {
      debugPrint('733ssd: Error storing share event notification: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getShareEventNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_shareEventNotificationKey);
    if (jsonString == null) return null;

    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      debugPrint('733ssd: Share event notification retrieved: $data');
      return data;
    } catch (e) {
      debugPrint('73ssd: Error decoding share event notification: $e');
      return null;
    }
  }

  static Future<void> clearShareEventNotification() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('733ssd: Share event notification cleared');
    await prefs.remove(_shareEventNotificationKey);
  }

  static Future<String?> getNewsDeepLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_newsDeepLinkKey);
  }

  static Future<void> clearNewsDeepLink() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_newsDeepLinkKey);
    debugPrint('73ssd: News deep link cleared');
  }

  static Future<void> clearDeepLink() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deepLinkKey);
  }

  static Future<void> setFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTime, true);
  }

  /// Check if it's user's first time using the app
  static Future<bool> isUserFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTime) ?? false;
  }

  static const String _timestampKey = 'app_timestamp';

  /// Saves the current timestamp (as an ISO8601 string) using SharedPreferences.
  static Future<void> saveTimestamp(DateTime timestamp) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timestampKey, timestamp.toIso8601String());
  }

  /// Retrieves the saved timestamp.
  /// Returns a [DateTime] if available, or null if not set or parsing fails.
  static Future<DateTime?> getTimestamp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(_timestampKey);
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// Deletes the stored timestamp.
  static Future<void> clearTimestamp() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_timestampKey);
  }
}
