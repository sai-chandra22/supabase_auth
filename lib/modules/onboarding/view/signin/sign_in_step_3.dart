import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/animators/resend_code_animation.dart';
import 'package:mars_scanner/modules/home_screen/view/app_screens_main_tab.dart';
import '../../../../cache/local/shared_prefs.dart';
import '../../../../helpers/haptics.dart';
import '../../controller/signin_controller.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/sign_in_step_2.dart';

import '../../../../common/animation.dart';
import '../../../../common/buttons/custom_button.dart';
import '../../../../common/textfields/otp_field.dart';
import '../../../../themes/app_text_theme.dart';
import '../../../../utils/app_texts.dart';
import '../../../../utils/asset_constants.dart';
import '../../../../utils/colors.dart';
import '../../model/user_model.dart';
import 'social_sign_in.dart';

class SignInStep3 extends StatefulWidget {
  final bool? fromStep2;
  final bool? isFromSocialSignIn;
  const SignInStep3({super.key, this.fromStep2, this.isFromSocialSignIn});

  @override
  State<SignInStep3> createState() => _SignInStep3State();
}

class _SignInStep3State extends State<SignInStep3>
    with TickerProviderStateMixin {
  TextEditingController otpController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isSignInPressed = false;
  final signInController = Get.find<SignInController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      signInController.isOtpInputStarted.value = false;
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  void navigateToHomeScreen() async {
    // _navigateToStep3Controller.forward();

    await Navigator.of(context).pushReplacement(
      createCustomPageRoute(
        const HomeScreenTabControl(
          isFromSplashScreen: true,
        ), // Ensure this flag is passed
        slideToLeft: true,
        duration: Duration(milliseconds: 400),
      ),
    );
  }

  setUserData() async {
    signInController.clearAllFields();
    final List<dynamic> userList = signInController.metaData['user'];
    final Map<String, dynamic> user = userList.isNotEmpty ? userList[0] : {};
    final String token = signInController.metaData['token'];

    debugPrint("user : $user"); // user details
    debugPrint("token : $token"); // token
    await LocalStorage.setUserModel(User.fromJson(user));
    await LocalStorage.setGraphQLApiToken(token);
  }

  String maskNumber(String numStr) {
    if (numStr.length <= 2) {
      return numStr; // If the number has 2 or fewer digits, return it as is
    }
    String masked = '*' * (numStr.length - 2); // Mask all but the last 2 digits
    return masked +
        numStr.substring(numStr.length - 2); // Append the last 2 digits
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenheight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        HapticFeedbacks.vibrate(FeedbackTypes.light);
        if (widget.isFromSocialSignIn == true) {
          Navigator.of(context).push(createCustomPageRoute(SocialSignIn(),
              fade: true, duration: Duration(milliseconds: 200)));
          setState(() {
            FocusScope.of(context).unfocus();
          });
        } else {
          Navigator.of(context).push(createCustomPageRoute(SignInStep2(),
              fade: true, duration: Duration(milliseconds: 250)));
        }

        return false;
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0 &&
              details.velocity.pixelsPerSecond.dx > 150) {
            if (widget.isFromSocialSignIn == true) {
              Navigator.of(context).push(createCustomPageRoute(SocialSignIn(),
                  fade: true, duration: Duration(milliseconds: 200)));
              setState(() {
                FocusScope.of(context).unfocus();
              });
            } else {
              Navigator.of(context).push(createCustomPageRoute(SignInStep2(),
                  fade: true, duration: Duration(milliseconds: 250)));
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 66.h),
                    padding: EdgeInsets.only(left: 24.w),
                    width: 393.w,
                    height: 24.h,
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: GestureDetector(
                        onTap: () {
                          //  HapticFeedbacks.vibrate(FeedbackTypes.light);
                          if (widget.isFromSocialSignIn == true) {
                            Navigator.of(context)
                                .push(createCustomPageRoute(SocialSignIn(),
                                    // InviteCodeWithoutCarousel(
                                    //   fromSignIn: true,
                                    // ),
                                    fade: true,
                                    duration: Duration(milliseconds: 200)));
                            setState(() {
                              FocusScope.of(context).unfocus();
                            });
                          } else {
                            Navigator.of(context).push(createCustomPageRoute(
                                SignInStep2(),
                                fade: true,
                                duration: Duration(milliseconds: 250)));
                          }
                          // Navigator.of(context).push(createCustomPageRoute(
                          //     SignInStep2(),
                          //     fade: true,
                          //     duration: Duration(milliseconds: 250)));
                        },
                        child: SvgPicture.asset(
                          AppAssets.chevronLeft,
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: Platform.isIOS
                          ? 10.h
                          : screenheight < 850
                              ? 12.h
                              : 9.h),
                  SvgPicture.asset(
                    AppAssets.marsMarketWord,
                  ),
                  SizedBox(height: 80.h),
                  SizedBox(
                    child: Text(
                      AppTexts.verification,
                      style: AppTextStyle.headerH2(
                          color: AppColors.white, letterSpacing: -0.1),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: 192.w,
                    height: 40.h,
                    child: CustomPinInput(
                      focusNode: focusNode,
                      length: 4,
                      otpController: signInController.otpController,
                      onChanged: (p0) {
                        signInController
                            .isUserInputOtp(signInController.otpController);
                      },
                      onCompleted: (value) async {
                        final flag = await signInController.verifySignInOtp();
                        if (flag) {
                          navigateToHomeScreen();
                          signInController.setUserData();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Obx(() {
                    return ResendCodeAnimatorText(
                      isOtpInputStarted:
                          signInController.isOtpInputStarted.value,
                      isOtpInvalid: signInController.isOTPInvalid.value,
                      onTap: () {
                        HapticFeedbacks.vibrate(FeedbackTypes.light);
                        signInController.sendOtpForSignIn(
                          signInController.provider != 'supabase_email_password'
                              ? signInController.email.value
                              : signInController.emailController.text.trim(),
                          signInController.passwordController.text.trim(),
                        );
                      },
                      isForSignIn: true,
                    );
                  }),
                  Spacer(),
                  if (!isKeyboardVisible)
                    CustomTextButton(
                      isActive: true,
                      // isOutlineType: true,
                      text: AppTexts.continueText.toUpperCase(),
                      textColor: AppColors.white,
                      backgroundColor: AppColors.marsOrange600,

                      onPressed: () {
                        // signInController.
                      },
                    ),
                  SizedBox(
                    height: 24.h,
                  )
                ],
              ),
              Obx(() {
                return signInController.isLoading.value
                    ? Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                              child: CupertinoActivityIndicator(
                            radius: 10.r,
                            color: AppColors.white,
                          )
                              //  CircularProgressIndicator(
                              //   color: AppColors.marsOrange600,
                              // ),
                              ),
                        ),
                      )
                    : const SizedBox.shrink(); // Hide if not loading
              }),
            ],
          ),
        ),
      ),
    );
  }
}
