import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/animation.dart';
import 'package:mars_scanner/modules/onboarding/controller/signin_controller.dart';
import 'package:mars_scanner/modules/onboarding/view/signup/verify_mail.dart';
import 'package:mars_scanner/utils/app_texts.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mars_scanner/utils/colors.dart';
import '../../../common/buttons/custom_button.dart';
import '../../../common/textfields/border_less_field.dart';
import '../../../themes/app_text_theme.dart';
import '../../helpers/custom_snackbar.dart';
import '../../helpers/haptics.dart';
import '../onboarding/view/signin/sign_in_step_2.dart';

class EnterEmail extends StatefulWidget {
  final bool doAnimation;
  final bool? isForPasswordChange;

  const EnterEmail(
      {super.key,
      this.doAnimation = false,
      this.userEmail = '',
      this.userId = '',
      this.isForPasswordChange});
  final String userEmail;
  final String userId;
  @override
  EnterEmailState createState() => EnterEmailState();
}

class EnterEmailState extends State<EnterEmail>
    with SingleTickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  late AnimationController _controller;
  late Animation<Offset> _emailOffsetAnimation;
  late Animation<double> _fadeAnimation;
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  String userId = '';

  void navigateToAccount() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    if (widget.isForPasswordChange == true) {
      final signInController = Get.find<SignInController>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _emailController.text = widget.userEmail.isEmpty
            ? signInController.email.value
            : widget.userEmail;
      });
    } else {
      _emailController.text = widget.userEmail;
      userId = widget.userId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _emailOffsetAnimation = Tween<Offset>(
      begin: const Offset(0, -8.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  void _navigateBack() {
    //  HapticFeedbacks.vibrate(FeedbackTypes.light);
    if (widget.isForPasswordChange == true) {
      _controller.reverse();
      Navigator.of(context).push(createCustomPageRoute(SignInStep2(),
          fade: true, duration: Duration(milliseconds: 250)));
    } else {
      _controller.reverse();
      navigateToAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: 38.h),
                  SlideTransition(
                    position: _emailOffsetAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(left: 32.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.emailAdress,
                            style: AppTextStyle.headerH3(
                              color: AppColors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(
                              height: widget.isForPasswordChange == true
                                  ? 16.h
                                  : 35.h),
                          SizedBox(
                            height: 32.h,
                            child: BorderLessTextField(
                              focusNode: focusNode,
                              controller: _emailController,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: CustomTextButton(
                          isActive: _isEmailValid,
                          text: AppTexts.continueText.toUpperCase(),
                          backgroundColor: AppColors.marsOrange600,
                          textColor: AppColors.white,
                          onPressed: () async {
                            HapticFeedbacks.vibrate(FeedbackTypes.light);
                            if (widget.isForPasswordChange != null) {
                              final signInController =
                                  Get.find<SignInController>();
                              final flag = await signInController
                                  .requestOtpForForgotPassword(
                                      _emailController.text.trim());
                              if (flag) {
                                Navigator.of(context)
                                    .push(createCustomPageRoute(
                                        VerifyEmail(
                                          isForPasswordChange: true,
                                          userEmail:
                                              _emailController.text.trim(),
                                        ),
                                        fade: true,
                                        duration: Duration(milliseconds: 250)));
                              }
                            } else {
                              if (widget.userEmail == _emailController.text) {
                                showCustomSnackbar(
                                    'Already same registered email',
                                    'Please use another email to update');
                              } else {}
                            }
                          }),
                    ),
                  ),
                ],
              ),
              Obx(() {
                if (widget.isForPasswordChange != null) {
                  final signInController = Get.find<SignInController>();
                  return signInController.isLoading.value
                      ? Positioned.fill(
                          child: Container(
                            height: 852.h,
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
                      : const SizedBox.shrink();
                } else {
                  return const SizedBox.shrink();
                }
                // Hide if not loading
              }),
            ],
          ),
        ),
      ),
    );
  }
}
