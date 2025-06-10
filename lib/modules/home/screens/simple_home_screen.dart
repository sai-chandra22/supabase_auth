import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/modules/home/screens/simple_login_screen.dart';
import '../../../cache/shared_prefs.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../common/animation.dart';
import '../../../helpers/custom_snackbar.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../../utils/colors.dart';
import '../../../themes/app_text_theme.dart';
import '../../../common/buttons/custom_button.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key, this.isFromSplashScreen});

  final bool? isFromSplashScreen;

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  final tokenExpiryManager = TokenExpiryManager();
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    handleSessionExpired();
  }

  Future<void> handleSessionExpired() async {
    if (widget.isFromSplashScreen == true) {
      debugPrint(
          '78ssd handleSessionExpired ${sb.Supabase.instance.client.auth.currentSession}');
      if (sb.Supabase.instance.client.auth.currentSession == null) {
        await LocalStorage.clearLocalData();
        showCustomSnackbar('Session Expired',
            'Your session has timed out. Please log in again.');
        Get.offAll(
          () => SimpleLoginScreen(),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    final user = await LocalStorage.getUserModel();
    if (user != null) {
      setState(() {
        userName = user.firstName ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Supabase Auth',
          style: AppTextStyle.headerH2(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: AppColors.marsOrange600,
              size: 80.r,
            ),
            SizedBox(height: 24.h),
            Text(
              'Welcome',
              style: AppTextStyle.headerH1(color: Colors.white),
            ),
            SizedBox(height: 8.h),
            Text(
              userName,
              style: AppTextStyle.headerH2(color: AppColors.marsOrange600),
            ),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CustomTextButton(
                isActive: true,
                text: 'LOGOUT',
                backgroundColor: AppColors.cardBackgroundFill,
                textColor: Colors.white,
                onPressed: () async {
                  await LocalStorage.clearLocalData();
                  TokenExpiryManager().logout();
                  Navigator.of(context)
                      .pushReplacement(createCustomSpringPageRoute(
                    SimpleLoginScreen(),
                    slideToRight: true,
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
