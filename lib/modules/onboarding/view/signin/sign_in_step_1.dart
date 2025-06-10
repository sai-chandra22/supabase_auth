import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/animation.dart';
import 'package:mars_scanner/common/buttons/custom_button.dart';
import 'package:mars_scanner/common/textfields/custom_textfield_widget.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/sign_in_step_2.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/social_sign_in.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:mars_scanner/utils/asset_constants.dart';

import '../../../../helpers/haptics.dart';
import '../../../../themes/app_text_theme.dart';
import '../../../../utils/app_texts.dart';
import '../../controller/signin_controller.dart';

class SignInStep1 extends StatefulWidget {
  final bool? fromInviteCode;

  const SignInStep1({super.key, this.fromInviteCode});

  @override
  State<SignInStep1> createState() => _SignInStep1State();
}

class _SignInStep1State extends State<SignInStep1>
    with TickerProviderStateMixin {
  TextEditingController otpController = TextEditingController();
  FocusNode focusNode = FocusNode();

  bool isSignInPressed = false;
  final TextEditingController _emailController = TextEditingController();
  final signInController = Get.find<SignInController>();
  bool _isEmailValid = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
    _emailController.addListener(_validateEmail);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.fromInviteCode == true ? Offset(0, 4) : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Cubic(0.175, 0.55, 0.32, 1.08),
    ));

    _animationController.forward();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    focusNode.dispose();
    otpController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void navigateToStep2() async {
    setState(() {
      isSignInPressed = true;
    });
    Navigator.of(context).push(
      createCustomPageRoute(
        const SignInStep2(),
        fade: true,
        duration: Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        HapticFeedbacks.vibrate(FeedbackTypes.light);
        signInController.clearAllFields();

        Navigator.of(context).push(createCustomPageRoute(SocialSignIn(),
            fade: true, duration: Duration(milliseconds: 200)));
        setState(() {
          FocusScope.of(context).unfocus();
        });
        return false;
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0 &&
              details.velocity.pixelsPerSecond.dx > 150) {
            signInController.clearAllFields();

            Navigator.of(context).push(createCustomPageRoute(SocialSignIn(),
                fade: true, duration: Duration(milliseconds: 200)));
            setState(() {
              FocusScope.of(context).unfocus();
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            alignment: Alignment.center,
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
                          signInController.clearAllFields();

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
                              ? 10.h
                              : 9.h),
                  SvgPicture.asset(
                    AppAssets.marsMarketWord,
                    // color: Colors.transparent,
                  ),
                  SizedBox(height: 80.h),

                  ///
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          child: Text(
                            'Welcome Back',
                            // AppTexts.enterEmail,
                            style: AppTextStyle.headerH2(
                                color: AppColors.white, letterSpacing: -0.1),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        SizedBox(
                            width: 313.w,
                            child: CustomTextField(
                              hintText: AppTexts.yourEmail,
                              textController: signInController.emailController,
                              focusNode: focusNode,
                              onChanged: (p0) {
                                signInController.validateEmail();
                              },
                            )),
                      ],
                    ),
                  ),

                  Flexible(
                    fit: FlexFit.loose,
                    child: Container(),
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Obx(() {
                      return CustomTextButton(
                        isActive: signInController.isEmailValid.value,
                        text: AppTexts.continueText.toUpperCase(),
                        backgroundColor: AppColors.marsOrange600,
                        textColor: AppColors.white,
                        onPressed: () {
                          HapticFeedbacks.vibrate(FeedbackTypes.light);
                          signInController.storeEmail(
                              signInController.emailController.text.trim());
                          navigateToStep2();
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 24.h),
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
