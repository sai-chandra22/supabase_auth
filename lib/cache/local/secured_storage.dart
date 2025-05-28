import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecuredStorage {
  static final _secureStorage = FlutterSecureStorage();

  // Store full name locally in Keychain
  static Future<void> saveFullName(String fullName) async {
    try {
      await _secureStorage.write(key: 'fullName_SCANNER', value: fullName);
    } catch (e) {
      debugPrint('Error saving full name to secure storage: $e');
    }
  }

  // Retrieve full name from Keychain
  static Future<String?> getStoredFullName() async {
    try {
      return await _secureStorage.read(key: 'fullName_SCANNER');
    } catch (e) {
      debugPrint('Error retrieving full name from secure storage: $e');
      return null;
    }
  }

  // Check if full name exists in Keychain
  static Future<bool> containsStoredFullName() async {
    try {
      return await _secureStorage.containsKey(key: 'fullName_SCANNER');
    } catch (e) {
      debugPrint('Error checking full name in secure storage: $e');
      return false;
    }
  }

  // Store email locally in Keychain
  static Future<void> saveEmail(String email) async {
    try {
      await _secureStorage.write(key: 'email_SCANNER', value: email);
    } catch (e) {
      debugPrint('Error saving email to secure storage: $e');
    }
  }

  // Retrieve email from Keychain
  static Future<String?> getStoredEmail() async {
    try {
      return await _secureStorage.read(key: 'email_SCANNER');
    } catch (e) {
      debugPrint('Error retrieving email from secure storage: $e');
      return null;
    }
  }

  // Check if email exists in Keychain
  static Future<bool> containsStoredEmail() async {
    try {
      return await _secureStorage.containsKey(key: 'email_SCANNER');
    } catch (e) {
      debugPrint('Error checking email in secure storage: $e');
      return false;
    }
  }

  // Store userIdentifier locally in Keychain
  static Future<void> saveUserIdentifier(String userIdentifier) async {
    try {
      await _secureStorage.write(
          key: 'userIdentifier_SCANNER', value: userIdentifier);
    } catch (e) {
      debugPrint('Error saving user identifier to secure storage: $e');
    }
  }

  // Retrieve userIdentifier from Keychain
  static Future<String?> getStoredUserIdentifier() async {
    try {
      return await _secureStorage.read(key: 'userIdentifier_SCANNER');
    } catch (e) {
      debugPrint('Error retrieving user identifier from secure storage: $e');
      return null;
    }
  }

  // Check if userIdentifier exists in Keychain
  static Future<bool> containsStoredUserIdentifier() async {
    try {
      return await _secureStorage.containsKey(key: 'userIdentifier_SCANNER');
    } catch (e) {
      debugPrint('Error checking user identifier in secure storage: $e');
      return false;
    }
  }

  // Delete all stored data from Keychain
  static Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      debugPrint('Error deleting all secure storage data: $e');
    }
  }

  // Delete a specific key-value pair from Keychain
  static Future<void> deleteKey(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting key ($key) from secure storage: $e');
    }
  }
}
