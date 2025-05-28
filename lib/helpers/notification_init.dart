// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../cache/local/shared_prefs.dart';
// import '../modules/home_screen/controller/home_controller.dart';
// import '../modules/home_screen/controller/notifcation_controller.dart';
// import '../modules/settings/controller/update_user_controller.dart';

// Future<void> initializeNotifications() async {
//   final updateController = Get.put(UpdateUserController());
//   final homeController = Get.find<HomeController>();

//   try {
//     final user = await LocalStorage.getUserModel();

//     NotificationController.to
//         .initializeFromUser(user?.enablePushNotifications ?? true);

//     // Initialize notifications service
//     //   final notificationService = NotificationService();
//     //   await notificationService.initialize();

//     // Check notification permission status after initialization
//     if (Platform.isIOS) {
//       final settings =
//           await FirebaseMessaging.instance.getNotificationSettings();

//       final isGranted =
//           settings.authorizationStatus == AuthorizationStatus.authorized;

//       if (user?.enablePushNotifications != isGranted) {
//         // Update user model
//         if (user != null) {
//           final updatedUser = user.copyWith(
//             enablePushNotifications: isGranted,
//           );
//           await LocalStorage.setUserModel(updatedUser);
//         }

//         updateController.toggleButton(value: isGranted);
//         NotificationController.to.toggleNotifications(isGranted);
//       }
//     } else {
//       final newStatus = await Permission.notification.status;
//       if (user?.enablePushNotifications != newStatus.isGranted) {
//         // Update user model
//         if (user != null) {
//           final updatedUser = user.copyWith(
//             enablePushNotifications: newStatus.isGranted,
//           );
//           await LocalStorage.setUserModel(updatedUser);
//         }

//         updateController.toggleButton(value: newStatus.isGranted);
//         NotificationController.to.toggleNotifications(newStatus.isGranted);
//       }
//     }

//     debugPrint('Notifications initialized successfully');
//     homeController.togglePrivacyMode(true);
//   } catch (e) {
//     debugPrint('Error initializing notifications: $e');
//   }
// }
