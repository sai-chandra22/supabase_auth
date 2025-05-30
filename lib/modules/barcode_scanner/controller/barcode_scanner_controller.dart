import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mars_scanner/helpers/custom_snackbar.dart';
import 'package:mars_scanner/modules/barcode_scanner/model/event_user_model.dart';
import 'package:mars_scanner/modules/home_screen/view/home_screen.dart';
import 'package:mars_scanner/services/graphQL/queries/event_queries.dart';

class BarcodeScannerController extends GetxController {
  // Observable for the scanned barcode result
  var scannedCode = RxString('');

  // Observable for loading/processing state
  var isLoading = false.obs;
  var isCheckInLoading = false.obs;

  // Observable for API response data
  var validationResponse = Rx<Map<String, dynamic>>({});
  var checkinResponse = Rx<Map<String, dynamic>>({});

  // Observable for validation and checkin status
  var isValidBarcode = false.obs;
  var isCheckedIn = false.obs;
  var errorMessage = RxString('');

  final RxString selectedCategory = ''.obs;
  final RxString category = 'ehp50ve2dkgux1h54fk08ecx'.obs;
  var isAlreadyCheckedIn = false.obs;

  final String alreadyCheckedIn = 'Event already checked in';

  Rx<EventUserModel?> eventUserData = Rx<EventUserModel?>(null);

  // Method to update the scanned code and validate it
  Future<void> updateScannedCode(String code) async {
    scannedCode.value = code;
    await validateBarcode(code);
  }

  // Clear the scanned code and reset states
  void clearScannedCode() {
    scannedCode.value = '';
    validationResponse.value = {};
    checkinResponse.value = {};
    isValidBarcode.value = false;
    isCheckedIn.value = false;
    isLoading.value = false;
    errorMessage.value = '';
    eventUserData.value = null;
    isAlreadyCheckedIn.value = false;
  }

  void updateCategory(String newCategory) {
    if (category.value != newCategory) {
      category.value = newCategory;
      debugPrint(" 915ssd: ${category.value}");
    }
  }

  // Validate the barcode
  Future<void> validateBarcode(String barcode) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await EventQueries.validateBarcode(barcode);
      final data = response['data']['validateBarcode'];
      final success = data['success'];

      prints('54ssd: $response');

      if (success) {
        final metadata = data['metadata'];
        if (metadata != null) {
          final decodedMetadata = jsonDecode(metadata);
          eventUserData.value = EventUserModel.fromJson(decodedMetadata);
          prints('eventUserData.value: ${eventUserData.value}');
          isValidBarcode.value = true;
          isLoading.value = false;
        } else {
          isValidBarcode.value = false;
          isLoading.value = false;
        }
      } else {
        if (data['message'] == alreadyCheckedIn) {
          if (checkedInUsers.isEmpty) {
            Get.back();
            showCustomSnackbar(
                'Oops!', 'Something went wrong, please try again',
                duration: 3);
          } else {
            // try to find the user by barcode
            final matches =
                checkedInUsers.where((u) => u.barcode == barcode).toList();

            if (matches.isNotEmpty) {
              // found them → update your eventUserData
              eventUserData.value = matches.first;
              isAlreadyCheckedIn.value = true;
              isValidBarcode.value = true;
            } else {
              Get.back();
              showCustomSnackbar(
                  'Oops!', 'Something went wrong, please try again',
                  duration: 3);
            }
          }
          isLoading.value = false;
        } else {
          isValidBarcode.value = false;
          errorMessage.value = data['message'] ?? 'Invalid barcode';
          isLoading.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error validating barcode: $e');
      isValidBarcode.value = false;
      errorMessage.value = 'Error: $e';
      isLoading.value = false;
    }
  }

  // Check in with the barcode
  Future<void> checkinWithBarcode({
    required String barcode,
    required EventUserModel model,
    void Function()? onSuccess,
    void Function()? onError,
  }) async {
    try {
      isCheckInLoading.value = true;

      final response = await EventQueries.checkinEvent(barcode);
      final data = response['data']['checkinEvent'];
      final success = data['success'];
      if (success) {
        final metadata = data['metadata'];
        if (metadata != null) {
          final decodedMetadata = jsonDecode(metadata);
          debugPrint('decodedMetadata: $decodedMetadata');
          final barcode = decodedMetadata['barcode'];
          final checkinTime = decodedMetadata['checkin_datetime'];
          final eventUserModel = EventUserModel(
            barcode: barcode,
            checkinTime: checkinTime,
            email: model.email,
            firstName: model.firstName,
            lastName: model.lastName,
            isCheckin: true,
            allowedGuests: model.allowedGuests,
            eventTitle: model.eventTitle,
            registeredGuests: model.registeredGuests,
            phoneNumber: model.phoneNumber,
          );

          if (!(checkedInUsers.any((element) => element.barcode == barcode))) {
            checkedInUsers.add(eventUserModel);
            update();
          }
          isCheckedIn.value = true;
          isCheckInLoading.value = false;
          onSuccess?.call();
        } else {
          isCheckedIn.value = false;
          isCheckInLoading.value = false;
          onError?.call();
        }
      } else {
        isCheckedIn.value = false;
        isCheckInLoading.value = false;
        onError?.call();
      }
    } catch (e) {
      showCustomSnackbar('Oops!', e.toString(), duration: 3);
      debugPrint('Error checking in: $e');
      isCheckedIn.value = false;
      isCheckInLoading.value = false;
      errorMessage.value = 'Check-in error: $e';
      onError?.call();
    }
  }

  var checkedInUsers = <EventUserModel>[].obs;
  var isCheckInUsersLoading = false.obs;

  // Check in with the barcode
  Future<void> getCheckedInUsers(String eventId, [bool? stopLoading]) async {
    try {
      if (stopLoading == null) {
        isCheckInUsersLoading.value = true;
      }

      final response = await EventQueries.getCheckinUsersForEvent(eventId);

      final data = response['data']['getCheckinUsersForEvent'];
      final success = data['success'];

      if (success) {
        final metadata = data['metadata'];
        if (metadata != null) {
          final decodedMetadata = jsonDecode(metadata);
          debugPrint('decodedMetadata: $decodedMetadata');

          List<dynamic> data = decodedMetadata;
          if (data.isNotEmpty) {
            // 1️⃣ build your new list
            final list =
                data.map((e) => EventUserModel.fromUsersList(e)).toList();

            // 2️⃣ compute the set of barcodes you just fetched
            final incomingBarcodes = list.map((m) => m.barcode).toSet();

            // 3️⃣ add any new ones
            final existingBarcodes =
                checkedInUsers.map((u) => u.barcode).toSet();
            final toAdd =
                list.where((m) => !existingBarcodes.contains(m.barcode));
            checkedInUsers.addAll(toAdd);

            // 4️⃣ remove any that aren’t in the incoming list
            checkedInUsers
                .removeWhere((u) => !incomingBarcodes.contains(u.barcode));

            checkedInUsers.sort((a, b) {
              final dateA = DateTime.parse(a.checkinTime!);
              final dateB = DateTime.parse(b.checkinTime!);
              return dateB.compareTo(dateA); // b.compareTo(a) for descending
            });
            prints('checkedInUsers: $checkedInUsers');
            update();
            isCheckInUsersLoading.value = false;
          }
        } else {
          checkedInUsers.value = [];
          isCheckInUsersLoading.value = false;
        }
      } else {
        checkedInUsers.value = [];
        isCheckInUsersLoading.value = false;
      }
    } catch (e) {
      debugPrint('Error checking in: $e');
      isCheckInUsersLoading.value = false;
    }
  }
}
