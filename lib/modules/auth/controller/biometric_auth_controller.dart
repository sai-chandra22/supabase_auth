import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

class BiometricAuthController extends GetxController {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final RxBool isBiometricsAvailable = false.obs;
  final RxBool hasDevicePassword = false.obs;
  final RxBool hasFaceId = false.obs;
  final RxBool hasFingerprint = false.obs;
  final RxBool hasBiometricWeak = false.obs;

  Future<void> checkBiometricSupport() async {
    try {
      // Reset all values
      isBiometricsAvailable.value = false;
      hasDevicePassword.value = false;
      hasFaceId.value = false;
      hasFingerprint.value = false;
      hasBiometricWeak.value = false;

      // Check device support with platform-specific handling
      try {
        hasDevicePassword.value = await _localAuth.isDeviceSupported();
      } catch (e) {
        debugPrint('Error checking device support: $e');
        // Fallback for iOS if the normal check fails
        if (Platform.isIOS) {
          hasDevicePassword.value = true; // iOS devices typically have security
        }
      }

      debugPrint('Device supports authentication: ${hasDevicePassword.value}');

      // Check biometric availability with error handling
      try {
        isBiometricsAvailable.value = await _localAuth.canCheckBiometrics;
      } catch (e) {
        debugPrint('Error checking biometric availability: $e');
        // Fallback based on platform
        if (Platform.isIOS) {
          isBiometricsAvailable.value = true;
        }
      }

      debugPrint('Can check biometrics: ${isBiometricsAvailable.value}');

      if (isBiometricsAvailable.value) {
        try {
          List<BiometricType> availableBiometrics =
              await _localAuth.getAvailableBiometrics();
          debugPrint('Available biometrics: $availableBiometrics');

          // Platform-specific biometric detection
          if (Platform.isIOS) {
            hasFaceId.value = availableBiometrics.contains(BiometricType.face);
            hasFingerprint.value =
                availableBiometrics.contains(BiometricType.fingerprint);
          } else {
            // For Android and other platforms
            hasFaceId.value =
                availableBiometrics.contains(BiometricType.face) ||
                    availableBiometrics.contains(BiometricType.weak);
            hasFingerprint.value =
                availableBiometrics.contains(BiometricType.fingerprint) ||
                    availableBiometrics.contains(BiometricType.weak);
          }

          hasBiometricWeak.value =
              availableBiometrics.contains(BiometricType.weak);
        } catch (e) {
          debugPrint('Error getting available biometrics: $e');
          // Fallback based on platform
          if (Platform.isIOS) {
            // Most modern iOS devices have Face ID or Touch ID
            hasFaceId.value = true;
          } else {
            // For Android, assume fingerprint as fallback
            hasFingerprint.value = true;
          }
        }

        debugPrint('Has Face ID: ${hasFaceId.value}');
        debugPrint('Has Fingerprint: ${hasFingerprint.value}');
        debugPrint('Has Weak Biometric: ${hasBiometricWeak.value}');
      }
    } catch (e) {
      debugPrint('General error in checkBiometricSupport: $e');
      // Set reasonable defaults if everything fails
      if (Platform.isIOS) {
        hasDevicePassword.value = true;
        isBiometricsAvailable.value = true;
        hasFaceId.value = true;
      } else {
        hasDevicePassword.value = true;
        isBiometricsAvailable.value = true;
        hasFingerprint.value = true;
      }
    }
  }

  Future<bool> authenticate() async {
    try {
      // If no security is set up, return true to allow access
      if (!hasDevicePassword.value && !isBiometricsAvailable.value) {
        debugPrint('No security available, allowing access');
        return true;
      }

      debugPrint('Attempting authentication...');
      bool result = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      debugPrint('Authentication result: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error during authentication: ${e.code}');
      // Handle specific cases for user cancellation or errors
      if (e.code == 'userCancel' ||
          e.code == 'authCancelled' ||
          e.code == 'userFallback') {
        debugPrint('Authentication canceled by the user');
        return false; // Authentication explicitly canceled
      }

      if (e.code == 'biometricNotAvailable' ||
          e.code == 'NotEnrolled' ||
          e.code == 'channel-error') {
        debugPrint('Authentication not available, allowing access');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Unexpected error during authentication: $e');
      // For unexpected errors, err on the side of allowing access
      return true;
    }
  }
}
