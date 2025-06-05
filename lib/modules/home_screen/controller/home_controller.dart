import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/modules/home_screen/view/home_screen.dart';

import '../../../services/graphQL/queries/event_queries.dart';
import '../../barcode_scanner/controller/barcode_scanner_controller.dart';

class HomeController extends GetxController {
  var isBottomNavVisible = true.obs; // Initially, it's visible
  var isFollowIconVisible = false.obs;
  var isHomeScreenVisible = true.obs;
  var isShareHolderMeeting = false.obs;

// Home Screen
  var whatsNextLoading = false.obs;
  var latestArtistsLoading = false.obs;
  var shareholderMeetingsLoading = false.obs;
  var highlightsLoading = false.obs;
  var isHomeAPIRunning = false.obs;
  var appVersion = ''.obs;

  var shareHolderData = {};

  var isLoading = false.obs; // Observable for loading state

  var isInitialized = false.obs;
  var mostRqstScroll = false.obs;

  var enablePrivacyMode = true.obs;

  var currenttab = 0.obs;

  void updateIndex(int index) {
    currenttab.value = index;
  }

  var isListLoading = false.obs;
  var meetingsList = RxMap<String, String>();

  Future<void> getMeetingsList() async {
    isListLoading.value = true;

    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final response = await EventQueries.getMeetingsList();

        final data = response['data']['getMeetingsList'];
        final success = data['success'];

        if (success) {
          final metadata = data['metadata'];
          if (metadata != null) {
            final Map<String, dynamic> decodedMetadata = jsonDecode(metadata);
            meetingsList.clear();
            for (var element in decodedMetadata.entries) {
              if (element.value != null) {
                meetingsList[element.value] = element.key;
              }
            }
            isListLoading.value = false;
            if (meetingsList.isNotEmpty) {
              final barcodeController = Get.find<BarcodeScannerController>();
              barcodeController.selectedCategory.value =
                  meetingsList.keys.first;
              barcodeController.category.value = meetingsList.values.first;
              barcodeController
                  .getCheckedInUsers(barcodeController.category.value);
            }

            prints('meetingsList: $meetingsList');
            break; // Success, exit retry loop
          }
        } else {
          isListLoading.value = false;
          break; // No success but no error, exit retry loop
        }
      } on DioException catch (dioErr) {
        attempt++;
        debugPrint('DioException on attempt $attempt: $dioErr');
        if (attempt >= maxRetries) {
          // All retries exhausted: exit
          isListLoading.value = false;
          break;
        } else {
          await Future.delayed(const Duration(seconds: 1));
          // Will retry on next loop iteration
        }
      } catch (e) {
        debugPrint('Error getting meetings list: $e');
        isListLoading.value = false;
        break; // Other errors, exit retry loop
      }
    }
  }
}
