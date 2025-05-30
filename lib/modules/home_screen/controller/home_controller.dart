import 'dart:convert';

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
    try {
      isListLoading.value = true;

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
            barcodeController.selectedCategory.value = meetingsList.keys.first;
            barcodeController.category.value = meetingsList.values.first;
            barcodeController
                .getCheckedInUsers(barcodeController.category.value);
          }

          prints('meetingsList: $meetingsList');
        }
      } else {
        isListLoading.value = false;
      }
    } catch (e) {
      debugPrint('Error checking in: $e');
      isListLoading.value = false;
    } finally {
      isListLoading.value = false;
    }
  }
}
