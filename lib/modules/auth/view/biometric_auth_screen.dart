//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/modules/auth/controller/biometric_auth_controller.dart';
import 'package:mars_scanner/modules/barcode_scanner/controller/barcode_scanner_controller.dart';
import 'package:mars_scanner/modules/home_screen/view/app_screens_main_tab.dart';

import '../../../common/animation.dart';
import '../../../themes/app_text_theme.dart';
import '../../../utils/colors.dart';
import '../../home_screen/controller/home_controller.dart';

class BiometricAuthScreen extends StatefulWidget {
  final String userName;
  const BiometricAuthScreen({super.key, required this.userName});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final BiometricAuthController _authController =
      Get.find<BiometricAuthController>();

  final HomeController homeController = Get.find<HomeController>();
  final BarcodeScannerController barcodeController =
      Get.find<BarcodeScannerController>();

  @override
  void initState() {
    super.initState();
    //  _initializeData();
    // Delay authentication slightly to ensure widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = await _authController.authenticate();
    // if (Platform.isIOS || Platform.isAndroid) {
    _initializeData();
    // }
    if (!mounted) return;
    if (authenticated) {
      _navigateToHome();
    }
  }

  Future<void> _initializeData() async {
    try {
      if (homeController.meetingsList.isEmpty &&
          !homeController.isListLoading.value) {
        homeController.getMeetingsList();
      }
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  void _navigateToHome() {
    debugPrint('712ssd: Starting navigation from biometric');
    final route = createCustomPageRoute(
      HomeScreenTabControl(
        isFromSplashScreen: true,
      ),
      topToBottom: true,
    );

    Navigator.of(context).pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Hi, ${widget.userName}',
                  style: AppTextStyle.headerH1(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 80.h),
                Obx(() {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_authController.hasFaceId.value ||
                          (_authController.hasBiometricWeak.value &&
                              !_authController.hasFingerprint.value)) ...[
                        Text(
                          'Face ID',
                          style: AppTextStyle.bodyLarge(color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        Image.asset('assets/images/face_id.png',
                            color: AppColors.hintColor,
                            width: 180.w,
                            height: 180.h)
                      ] else if (_authController.hasFingerprint.value ||
                          (_authController.hasBiometricWeak.value &&
                              !_authController.hasFaceId.value)) ...[
                        Text(
                          'Fingerprint',
                          style:
                              AppTextStyle.eyebrowLarge(color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.h),
                        Image.asset('assets/images/finger_print.png',
                            color: AppColors.hintColor,
                            width: 180.w,
                            height: 180.h)
                      ] else if (_authController.hasDevicePassword.value) ...[
                        Text(
                          'Device Password',
                          style: AppTextStyle.headerH2(color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Icon(
                          Icons.lock_outline,
                          size: 180.w,
                          color: AppColors.hintColor,
                        ),
                      ],
                      SizedBox(height: 24.h),
                      TextButton(
                        onPressed: _authenticate,
                        child: Text(
                          'Tap to Authenticate',
                          style: AppTextStyle.bodyLarge(color: AppColors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 80.h),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
