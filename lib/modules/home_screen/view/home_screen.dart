import 'dart:core';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/buttons/custom_button.dart';
import 'package:mars_scanner/themes/app_text_theme.dart';
import 'package:mars_scanner/utils/asset_constants.dart';

import 'package:mars_scanner/utils/colors.dart';
import '../../barcode_scanner/view/barcode_scanner_screen.dart';
import '../../barcode_scanner/controller/barcode_scanner_controller.dart';

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
          padding: EdgeInsets.only(top: 66.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () {
                      showLogoutSheet(context);
                    },
                  ),
                ],
              ),
              Expanded(
                child: Transform.translate(
                  offset: Offset(0, -70.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 0.w),
                        child: Baseline(
                          baseline: 28.h,
                          baselineType: TextBaseline.alphabetic,
                          child: Text("MARS SCANNER",
                              style: AppTextStyle.headerH1Brand(
                                color: Colors.white,
                                lineHeight: 1,
                                letterSpacing: 0,
                              )),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: SizedBox(
                          width: 220.w,
                          height: 400.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: SvgPicture.asset(
                                    AppAssets
                                        .meetingCard2, // Your SVG asset path
                                    fit: BoxFit
                                        .cover, // Fill the entire container
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.w, 22.h, 16.w, 42.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SvgPicture.asset(
                                        AppAssets.iconAsvg,
                                        height: 20.h,
                                        width: 12.w,
                                        color: Colors.black,
                                      ),
                                      SizedBox(
                                        child: Image.asset(
                                          AppAssets.barcode,
                                          height: 110.h,
                                          width: 120.w,
                                          // fit: BoxFit.fill,
                                        ),
                                      ),
                                      Text(
                                        'Tap the button below to scan a barcode'
                                            .toUpperCase(),
                                        style: AppTextStyle.bodyRegular(
                                          color: AppColors.white,
                                        ).copyWith(
                                          fontSize: 12.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      CustomTextButton(
                                          outlineThickness: 1.w,
                                          width: 150.w,
                                          outlineWidth: 152.w,
                                          isOutlineType: true,
                                          outlineColor: AppColors.black,
                                          backgroundColor: AppColors.black,
                                          text: 'SCAN',
                                          textColor: AppColors.white,
                                          onPressed: () {
                                            final barcodeController = Get.find<
                                                BarcodeScannerController>();
                                            barcodeController
                                                .clearScannedCode();

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const BarcodeScannerScreen(),
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                )
                              ],
                            ),
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
