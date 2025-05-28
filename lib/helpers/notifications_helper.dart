import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/onboarding/controller/signin_controller.dart';
import '../modules/onboarding/controller/signup_controller.dart';

Future<void> requestNotificationPermission() async {
  final firebaseMessaging = FirebaseMessaging.instance;
  final settings = await firebaseMessaging.getNotificationSettings();
  if (settings.authorizationStatus != AuthorizationStatus.authorized) {
    await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (Platform.isIOS) {
      await firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}

void getFCMToken() async {
  final signUpController = Get.find<SignUpController>();
  final signInController = Get.find<SignInController>();
  final firebaseMessaging = FirebaseMessaging.instance;
  try {
    if (Platform.isIOS) {
      String? apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        await firebaseMessaging.subscribeToTopic('notificationTokens');
      } else {
        await Future<void>.delayed(
          const Duration(
            seconds: 3,
          ),
        );
        apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.subscribeToTopic('notificationTokens');
        }
      }
    } else {
      await firebaseMessaging.subscribeToTopic('notificationTokens');
    }

    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final fcmToken = await FirebaseMessaging.instance.getToken();

    debugPrint('FCM Token: $fcmToken');
    signUpController.setFCMToken(fcmToken ?? '');
    signInController.setFCMToken(fcmToken ?? '');
  } catch (e) {
    debugPrint('Error getting FCM token or device ID: $e');
  }
}
