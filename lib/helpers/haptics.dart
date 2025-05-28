import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum FeedbackTypes {
  light,
  success,
  error,
  soft,
}

class HapticFeedbacks {
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_hapticEnabledKey)) {
      await prefs.setBool(_hapticEnabledKey, true); // Set default to true
    }
  }

  static const String _hapticEnabledKey = 'haptic_enabled';

  static Future<void> setHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticEnabledKey, enabled);
  }

  static Future<bool> isHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticEnabledKey) ??
        true; // Default to true if not set
  }

  static Future<bool> canVibrate() async {
    final isEnabled = await isHapticEnabled();
    debugPrint('isEnabled: $isEnabled');
    if (!isEnabled) return false;
    return await Haptics.canVibrate();
  }

  static Future<void> vibrate(FeedbackTypes type) async {
    final canDeviceVibrate = await canVibrate();

    debugPrint('canVibrate: $canDeviceVibrate');
    if (!canDeviceVibrate) return;

    switch (type) {
      case FeedbackTypes.light:
        await Haptics.vibrate(HapticsType.light);
      case FeedbackTypes.success:
        await Haptics.vibrate(HapticsType.success);
      case FeedbackTypes.error:
        await Haptics.vibrate(HapticsType.error);
      case FeedbackTypes.soft:
        await Haptics.vibrate(HapticsType.soft);
    }
  }
}
