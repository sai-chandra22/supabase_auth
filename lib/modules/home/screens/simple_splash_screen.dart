import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../cache/shared_prefs.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../../utils/colors.dart';
import 'simple_home_screen.dart';
import 'simple_login_screen.dart';

class SimpleSplashScreen extends StatefulWidget {
  const SimpleSplashScreen({super.key});

  @override
  State<SimpleSplashScreen> createState() => _SimpleSplashScreenState();
}

class _SimpleSplashScreenState extends State<SimpleSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  Future<void> _checkUserLoginStatus() async {
    // Wait for token expiry manager to initialize
    await TokenExpiryManager.initialized;

    // Short delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    final user = await LocalStorage.getUserModel();

    if (user != null) {
      // User is logged in, navigate to home screen
      Get.off(() => const SimpleHomeScreen(isFromSplashScreen: true));
    } else {
      // User is not logged in, navigate to login screen
      Get.off(() => const SimpleLoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 80.r,
            ),
            SizedBox(height: 24.h),
            Text(
              'Supabase Auth',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40.h),
            CircularProgressIndicator(
              color: AppColors.marsOrange600,
            ),
          ],
        ),
      ),
    );
  }
}
