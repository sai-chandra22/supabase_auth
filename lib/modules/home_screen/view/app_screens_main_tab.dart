import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/modules/barcode_scanner/view/checked_in_users_list_screen.dart';
import 'package:mars_scanner/modules/home_screen/view/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/glassmorph_nav_bar.dart';
import '../../../helpers/haptics.dart';
import '../../../themes/app_text_theme.dart';
import '../../../utils/colors.dart';
import '../../barcode_scanner/controller/barcode_scanner_controller.dart';
import '../controller/home_controller.dart';

class HomeScreenTabControl extends StatefulWidget {
  final bool isFromSplashScreen;

  const HomeScreenTabControl({
    super.key,
    this.isFromSplashScreen = false,
  });

  @override
  State<HomeScreenTabControl> createState() => _HomeScreenTabControlState();
}

class _HomeScreenTabControlState extends State<HomeScreenTabControl>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  final homeController = Get.find<HomeController>();
  final barcodeController = Get.find<BarcodeScannerController>();
  // Get.put(HomeController());

  final screenNames = [
    'Home Screen',
    'CheckIn Screen',
  ];
  late StreamSubscription _sub;
  bool isNotificationOpen = false;

  @override
  void initState() {
    super.initState();
    debugPrint("initState of HomeScreenTabControl 70ssd");

    //  _initializeNotifications();
    _currentIndex = homeController.currenttab.value;
    _pageController = PageController(initialPage: _currentIndex);
    if (widget.isFromSplashScreen == true) {
      _initializeData();
    }
    requestCameraPermissions();
  }

  Future<void> requestCameraPermissions() async {
    final PermissionStatus status = await Permission.camera.request();
    debugPrint('263ssd: $status');
  }

  Future<void> _initializeData() async {
    try {
      if (homeController.meetingsList.isEmpty &&
          !homeController.isListLoading.value) {
        await homeController.getMeetingsList();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }

    // try {
    //   if (barcodeController.checkedInUsers.isEmpty &&
    //       !barcodeController.isCheckInUsersLoading.value) {
    //     barcodeController.getCheckedInUsers(barcodeController.category.value);
    //   }
    // } catch (e) {
    //   debugPrint('Error initializing data for checkedInUsers: $e');
    // }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Screens for each tab

  void _onTabSelected(int index) async {
    debugPrint("index = $index");
    if (index == _currentIndex) return; // Ignore if the same tab is tapped

    // Animate the page transition based on direction
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentIndex = index;
        HapticFeedbacks.vibrate(FeedbackTypes.soft);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 380),
          curve: Cubic(0.175, 0.885, 0.32,
              1.14), // Smooth transition for both directions
        );
      });
    });

    homeController.updateIndex(index); // Notify the controller
  }

  navigateBack() async {
    if (_currentIndex > 0) {
      final index = _currentIndex - 1;
      _onTabSelected(index);
      _currentIndex = index;
    } else {
      final brightness = Theme.of(context).brightness;
      final textColor = brightness == Brightness.dark
          ? AppColors.white
          : AppColors.background;
      final shouldExit = await showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoTheme(
          data: CupertinoThemeData(
            barBackgroundColor: textColor,
            brightness: brightness,
          ),
          child: CupertinoAlertDialog(
            title: Text(
              'Exit App',
              style: AppTextStyle.headerH3(color: textColor),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'Are you sure you want to exit?',
                style: AppTextStyle.bodyLarge(color: textColor),
              ),
            ),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'No',
                  style: AppTextStyle.headerH3(color: AppColors.marsOrange600),
                ),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Yes',
                  style: AppTextStyle.headerH3(color: textColor),
                ),
              ),
            ],
          ),
        ),
      );

      if (shouldExit ?? false) {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FocusScope.of(context).unfocus();
    });

    // final bool isFromSplashScreen = widget.isFromSplashScreen != null;
    final List<Widget> screens = [
      const HomeScreen(),
      CheckedInUsersListScreen(onTap: () {})
    ];
    return Obx(() {
      _onTabSelected(homeController.currenttab.value);
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          navigateBack();
          return;
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 0 &&
                  details.velocity.pixelsPerSecond.dx > 150) {
                navigateBack();
              }

              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < 0 &&
                  details.velocity.pixelsPerSecond.dx < -150) {
                if (_currentIndex < 3) {
                  final index = _currentIndex + 1;
                  _onTabSelected(index);
                  _currentIndex = index;
                }
              }
            },
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.only(
                      top: homeController.isHomeScreenVisible.value ? 0 : 0.h),
                  child: PageView(
                    controller: _pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable manual scrolling
                    children: screens.map((screen) {
                      return screen;
                    }).toList(),
                  ),
                ),

                // Persistent custom app bar
                // if (_currentIndex == 1) ...[
                //   const SearchBarField(),
                // ] else ...[
                //   AnimatedOpacity(
                //       opacity: ((_currentIndex == 0 &&
                //                   homeController.getScrollPosition() < 35) ||
                //               (_currentIndex == 3 &&
                //                   homeController.getPortFolioScrollPosition() <
                //                       35))
                //           ? 1.0
                //           : (_currentIndex == 2)
                //               ? 1.0
                //               : 0.0,
                //       duration: const Duration(milliseconds: 400),
                //       child: CustomAppBar(
                //         isForNewsScreen: _currentIndex == 2 ? true : null,
                //       )),
                // ],

                Obx(() {
                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    bottom: homeController.isBottomNavVisible.value
                        ? 0
                        : -100, // Show/hide nav bar
                    left: ScreenUtil().screenWidth * 0.31,
                    right: ScreenUtil().screenWidth * 0.31,
                    child: GlassMorphicNavBar(
                      currentIndex: _currentIndex, // Define the current index
                      onTabSelected: (index) {
                        _onTabSelected(index);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }
}
