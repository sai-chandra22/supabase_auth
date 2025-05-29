import 'dart:core';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mars_scanner/utils/colors.dart';
import '../../barcode_scanner/view/barcode_scanner_screen.dart';

import '../../../cache/local/shared_prefs.dart';
import '../../../common/animation.dart';
import '../../../helpers/caution.popup.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../onboarding/view/onBoarding_carousel/onboarding_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final mostRqstScrollController = ScrollController();
//  final expScrnArtistsScrollController = ScrollController();
  CarouselSliderController carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          padding: EdgeInsets.only(top: 57.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: Text(
                      'Mars Scanner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      showLogoutSheet(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150.w,
                        height: 150.w,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Icon(
                          Icons.qr_code_scanner,
                          size: 80.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Scan Barcode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Tap the button below to scan a barcode',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40.h),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BarcodeScannerScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Start Scanning',
                          style: TextStyle(
                            color: AppColors.background,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

void prints(var s1) {
  String s = s1.toString();
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
}

Future<void> showLogoutSheet(BuildContext context) async {
  showModalBottomSheet(
    sheetAnimationStyle: AnimationStyle(
      duration: const Duration(milliseconds: 200), // Duration of animation
      curve: Curves.bounceInOut, // Customize the animation curve
      reverseCurve: Curves.easeOut, // Customize reverse animation curve
    ),
    useSafeArea: true,
    isDismissible: true,
    backgroundColor: AppColors.white,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r), // Add a radius of 36 to top left and right
      ),
    ),
    builder: (context) => ShmCautionPopUp(
      isForLogOut: true,
      onTap: () async {
        final authToken = await LocalStorage.getGraphQLApiToken();
        prints("authToken: $authToken");
        await LocalStorage.clearLocalData();
        TokenExpiryManager().logout();
        Navigator.of(context).pushReplacement(createCustomSpringPageRoute(
          OnboardingCarousel(
            isFromIntro: true,
            initialPage: 3,
            isNotFirstTime: true,
          ),
          //  OnboardingIntro(isFromInviteCode: true),
          slideToRight: true,
        ));
      },
    ),
  );
}
