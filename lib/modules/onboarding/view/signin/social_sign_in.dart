import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/buttons/social_buttons.dart';
import 'package:mars_scanner/modules/onboarding/controller/signin_controller.dart';
import 'package:mars_scanner/modules/onboarding/view/onBoarding_carousel/onboarding_carousel.dart';
import 'package:mars_scanner/modules/onboarding/view/onBoarding_carousel/onboarding_carousel_login.dart';
import 'package:mars_scanner/utils/asset_constants.dart';

import '../../../../cache/local/shared_prefs.dart';
import '../../../../common/animation.dart';
import '../../../../helpers/haptics.dart';
import '../../../../utils/app_texts.dart';
import '../../../../utils/colors.dart';
import 'sign_in_step_1.dart';
import 'sign_in_step_3.dart';

class SocialSignIn extends StatefulWidget {
  const SocialSignIn({super.key});

  @override
  State<SocialSignIn> createState() => _SocialSignInState();
}

class _SocialSignInState extends State<SocialSignIn> {
  final signInControler = Get.find<SignInController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    setIsFirstTime();
    super.initState();
  }

  setIsFirstTime() async {
    await LocalStorage.setFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    final screenheight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        HapticFeedbacks.vibrate(FeedbackTypes.light);
        Navigator.of(context).push(createCustomPageRoute(
            OnboardingCarousel(
              initialPage: 3,
              isNotFirstTime: true,
            ),
            fade: true,
            duration: Duration(milliseconds: 200)));
        return false; // Prevent default back action
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0 &&
              details.velocity.pixelsPerSecond.dx > 150) {
            //  HapticFeedbacks.vibrate(FeedbackTypes.light);
            Navigator.of(context).push(createCustomPageRoute(
                OnboardingCarousel(
                  initialPage: 3,
                  isNotFirstTime: true,
                ),
                fade: true,
                duration: Duration(milliseconds: 200)));
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 66.h),
                    // Chevron icon to go back
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 24.w),
                      width: 393.w,
                      height: 24.h,
                      child: SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: GestureDetector(
                          onTap: () {
                            //  HapticFeedbacks.vibrate(FeedbackTypes.light);
                            Navigator.of(context).push(createCustomPageRoute(
                                OnboardingCarousel(
                                  initialPage: 3,
                                  isNotFirstTime: true,
                                ),
                                fade: true,
                                duration: Duration(milliseconds: 200)));
                            setState(() {
                              FocusScope.of(context).unfocus();
                            });
                          },
                          child: SvgPicture.asset(
                            AppAssets.chevronLeft,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.5.h),
                    SvgPicture.asset(
                      AppAssets.marsMarketWord,
                      color: Colors.transparent,
                    ),
                    SizedBox(height: 20.h),
                    OnBoardingCarouselLoginLottie(
                      height: 484.h,
                    ),
                    SizedBox(height: 16.h),
                    SocialLoginButtons(
                      showIcon: true,
                      iconPath: AppAssets.envelope,
                      text: AppTexts.singInWEmail.toUpperCase(),
                      onPressed: () {
                        HapticFeedbacks.vibrate(FeedbackTypes.light);
                        Navigator.push(
                            context,
                            createCustomPageRoute(
                                SignInStep1(
                                  fromInviteCode: true,
                                ),
                                fade: true,
                                duration: Duration(milliseconds: 200)));
                      },
                    ),

                    SizedBox(height: 158.h),
                  ],
                ),
                Transform.translate(
                  offset: Offset(0, -315.h),
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: Platform.isIOS
                            ? 5.2.h
                            : screenheight < 850
                                ? 5.2.h
                                : 3.4.h),
                    child: SvgPicture.asset(
                      AppAssets.marsMarketWord,
                    ),
                  ),
                ),
                Obx(() {
                  return signInControler.isLoading.value
                      ? Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            padding: EdgeInsets.only(top: 200.h),
                            child: Center(
                                child: CupertinoActivityIndicator(
                              radius: 10.r,
                              color: AppColors.white,
                            )
                                // CircularProgressIndicator(
                                //   color: AppColors.marsOrange600,
                                // ),
                                ),
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void navigateToStep3() async {
    Navigator.of(context).push(
      createCustomPageRoute(
        const SignInStep3(
          isFromSocialSignIn: true,
        ), // Ensure this flag is passed
        fade: true,
        duration: Duration(milliseconds: 250),
      ),
    );
  }
}
