import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/modules/settings/settings_enter_email.dart';
import '../../../../helpers/haptics.dart';
import '../../controller/signin_controller.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/sign_in_step_1.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/sign_in_step_3.dart';
import 'package:mars_scanner/utils/app_texts.dart';
import 'package:mars_scanner/utils/colors.dart';

import '../../../../common/animation.dart';
import '../../../../common/buttons/custom_button.dart';
import '../../../../common/textfields/custom_textfield_widget.dart';
import '../../../../themes/app_text_theme.dart';
import '../../../../utils/asset_constants.dart';

class SignInStep2 extends StatefulWidget {
  final bool? fromStep1;
  final bool? fromStep3;

  const SignInStep2(
      {super.key, this.fromStep1 = false, this.fromStep3 = false});

  @override
  SignInStep2State createState() => SignInStep2State();
}

class SignInStep2State extends State<SignInStep2>
    with TickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  late AnimationController _controller;
  late Animation<Offset> _emailOffsetAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _navigateToStep3Controller;
  late Animation<Offset> _marsMarketOffsetAnimationToStep3;
  // late Animation<double> _fadeAnimationToStep3;
  late AnimationController _returnFromStep3Controller;
  late Animation<Offset> _marsMarketOffsetAnimationFromStep3;
  late Animation<double> _fadeAnimationFromStep3;
  late Animation<double> _fadeAnimationToStep3;

  bool isSignInPressed = false;

  // final TextEditingController _passwordController = TextEditingController();
  final signInController = Get.find<SignInController>();

  @override
  void initState() {
    super.initState();
    // Initialize the animation controllers
    _navigateToStep3Controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Define animations for navigating to Step3
    _marsMarketOffsetAnimationToStep3 = Tween<Offset>(
      begin: const Offset(0, 0.0),
      end: const Offset(0, -8.0), // Adjust the offset to move out of view
    ).animate(CurvedAnimation(
      parent: _navigateToStep3Controller,
      curve: Curves.slowMiddle,
    ));

    _returnFromStep3Controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Define animations for returning from Step3
    _marsMarketOffsetAnimationFromStep3 = Tween<Offset>(
      begin: const Offset(0, -8.0), // Start out of view
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: _returnFromStep3Controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    _fadeAnimationFromStep3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _returnFromStep3Controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.fromStep3 == true) {
      _returnFromStep3Controller.forward();
    }

    _fadeAnimationToStep3 = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _navigateToStep3Controller,
      curve: Curves.easeOutCubic,
    ));
  }

  void navigateToStep1() async {
    Navigator.of(context).push(
      createCustomPageRoute(
        SignInStep1(
            // fromStep2: true,
            ),
        fade: true,
        duration: Duration(milliseconds: 200),
      ),
    );
    signInController.passwordController.clear();
  }

  void navigateToStep3() async {
    setState(() {
      isSignInPressed = true;
    });
    // _navigateToStep3Controller.forward();
    Navigator.of(context).push(
      createCustomPageRoute(
        const SignInStep3(), // Ensure this flag is passed
        fade: true,
        duration: Duration(milliseconds: 250),
      ),
    );
  }

  @override
  void dispose() {
    _navigateToStep3Controller.dispose();
    _returnFromStep3Controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _navigateBack() {
    // _controller.reverse();
    // HapticFeedbacks.vibrate(FeedbackTypes.light);
    navigateToStep1();
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0 &&
              details.velocity.pixelsPerSecond.dx > 150) {
            _navigateBack();
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
                        onTap: _navigateBack,
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
                              ? 10.h
                              : 9.h),
                  SvgPicture.asset(
                    AppAssets.marsMarketWord,
                  ),
                  SizedBox(height: 80.h),
                  SizedBox(
                    child: Text(
                      'Welcome Back',
                      // AppTexts.signIn,
                      style: AppTextStyle.headerH2(
                          color: AppColors.white, letterSpacing: -0.1),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                      width: 313.w,
                      child: CustomTextField(
                        onChanged: (value) {
                          signInController.validatePassword();
                        },
                        textController: signInController.passwordController,
                        hintText: AppTexts.yourPassword,
                        isForPassword: true,
                      )),
                  SizedBox(height: 40.h),
                  GestureDetector(
                    onTap: () {
                      HapticFeedbacks.vibrate(FeedbackTypes.light);
                      Navigator.of(context).push(
                        createCustomPageRoute(
                          const EnterEmail(
                            isForPasswordChange: true,
                          ),
                          fade: true,
                          duration: Duration(milliseconds: 250),
                        ),
                      );
                    },
                    child: Text(
                      AppTexts.forgotYourPassword,
                      style: AppTextStyle.bodySmall(
                              lineHeight: 1.2,
                              color: AppColors.grey,
                              letterSpacing: -0.1)
                          .copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: widget.fromStep3 == true
                        ? isSignInPressed == true
                            ? _fadeAnimationToStep3
                            : _fadeAnimationFromStep3
                        : _fadeAnimationToStep3,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Obx(() {
                        return CustomTextButton(
                            isActive: signInController.isPasswordValid.value,
                            text: AppTexts.continueText.toUpperCase(),
                            backgroundColor: AppColors.marsOrange600,
                            textColor: AppColors.white,
                            onPressed: () async {
                              HapticFeedbacks.vibrate(FeedbackTypes.light);
                              signInController.setProviderToNormal();
                              final flag =
                                  await signInController.sendOtpForSignIn(
                                signInController.emailController.text.trim(),
                                signInController.passwordController.text.trim(),
                              );
                              if (flag) {
                                navigateToStep3();
                              }
                            });
                      }),
                    ),
                  ),
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
                              // CircularProgressIndicator(
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
