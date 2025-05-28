import 'package:get/get.dart';

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
}
