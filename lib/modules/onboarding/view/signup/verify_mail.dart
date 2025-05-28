import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/animators/resend_code_animation.dart';
import 'package:mars_scanner/common/textfields/otp_field.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/forgot_password/sign_in_change_password.dart';
import 'package:mars_scanner/modules/onboarding/view/signup/create_password.dart';
import 'package:mars_scanner/modules/settings/settings_enter_email.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mars_scanner/modules/onboarding/controller/signup_controller.dart';
import '../../../../helpers/haptics.dart';
import '../../controller/signin_controller.dart';
import '/utils/app_texts.dart';
import 'package:mars_scanner/themes/app_text_theme.dart';
import 'package:mars_scanner/common/animation.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({
    super.key,
    this.isForCarousel,
    this.focusNode,
    this.pageController,
    this.userEmail = '',
    this.userId = '',
    this.isForPasswordChange,
    this.isForNormalSignUp,
  });

  final bool? isForCarousel;
  final FocusNode? focusNode;
  final PageController? pageController;
  final String userEmail;
  final String userId;
  final bool? isForPasswordChange;
  final bool? isForNormalSignUp;

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail>
    with TickerProviderStateMixin {
  TextEditingController otpController = TextEditingController();
  late FocusNode _focusNode;
  final SignUpController signUpController = Get.find<SignUpController>();
  bool isOtpInputStarted = false; // Tracks if OTP input has started
  bool isOtpInvalid = false; // Tracks if OTP is invalid
  String userEmail = '';
  String userId = '';
  // final updateUserController = Get.put(UpdateUserController());

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.pageController != null) {
      widget.pageController!.addListener(() {
        if (widget.pageController!.page == 2.0 ||
            (widget.pageController!.page == 3.0 &&
                widget.isForNormalSignUp == true)) {
          _focusNode.requestFocus();
        }
      });
    }
    userEmail = widget.userEmail;
    userId = widget.userId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      signUpController.isOtpInputStarted.value = false;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    otpController.dispose();
    super.dispose();
  }

  void navigateToStep2() async {
    Navigator.of(context).push(
      CustomPageRoute(
        child: const CreatePassword(), // Ensure this flag is passed
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return widget.isForCarousel != null
        ? forCarouselScreen()
        : verifyMailScreen(context, isKeyboardVisible);
  }

  Widget forCarouselScreen() {
    return Container(
      padding: EdgeInsets.only(left: 32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.enterEmailCode,
            style: AppTextStyle.bodyRegular(
                color: AppColors.grey, letterSpacing: 0),
          ),
          SizedBox(height: 40.h),
          SizedBox(
            width: 152.w,
            height: 40.h,
            child: CustomPinInput(
              autoFocus: true,
              focusNode: _focusNode,
              length: 4,
              otpController: signUpController.emailOtpController,
              // otpController,
              onChanged: (p0) {
                signUpController
                    .isUserInputOtp(signUpController.emailOtpController);
              },
              onCompleted: (value) {
                // validateOTP(otpController.text);
                signUpController
                    .verifyOtpForSignUpEmail(
                        signUpController.emailController.text.trim(),
                        signUpController.emailOtpController.text.trim())
                    .then((value) {
                  if (value) {
                    if (widget.pageController != null) {
                      widget.pageController!.nextPage(
                        duration: const Duration(milliseconds: 350),
                        curve: const Cubic(0.175, 0.885, 0.32, 1.12),
                      );
                      // signUpController.isEmailOtpValid.value = false;
                      signUpController.emailOtpController.clear();
                    }
                  }
                });
              },
            ),
          ),
          SizedBox(height: 48.h),
          Obx(() {
            return ResendCodeAnimatorText(
              isOtpInputStarted: signUpController.isOtpInputStarted.value,
              isOtpInvalid: signUpController.isOTPInvalid.value,
              onTap: () {
                HapticFeedbacks.vibrate(FeedbackTypes.light);
                signUpController.requestOtpForSignUpEmailMethod(
                    widget.userEmail.isNotEmpty
                        ? widget.userEmail
                        : signUpController.emailController.text.trim());
              },
            );
          })
        ],
      ),
    );
  }

  Widget resendText() {
    return Visibility(
      child: Row(
        children: [
          Text(
            AppTexts.receiveCodeQtn,
            textAlign: TextAlign.start,
            style: AppTextStyle.bodyRegular(
              color: AppColors.grey,
              letterSpacing: 0,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () {},
            child: Text(
              AppTexts.resend,
              style: AppTextStyle.bodyRegularBold(
                      color: AppColors.white, letterSpacing: 0)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget verifyMailScreen(BuildContext context, bool isKeyboardVisible) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isForPasswordChange == true) {
          Navigator.of(context).push(createCustomPageRoute(
              EnterEmail(
                isForPasswordChange: true,
              ),
              fade: true,
              duration: Duration(milliseconds: 250)));
        } else {}

        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
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
                          if (widget.isForPasswordChange == true) {
                            Navigator.of(context).push(createCustomPageRoute(
                                EnterEmail(
                                  isForPasswordChange: true,
                                  userEmail: widget.userEmail,
                                ),
                                fade: true,
                                duration: Duration(milliseconds: 250)));
                          }
                        },
                        child: SvgPicture.asset(
                          AppAssets.chevronLeft,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: 393.w,
                    height: 433.h,
                    child: Container(
                      width: 345.w,
                      margin: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 200.h),
                      padding: EdgeInsets.only(
                        left: 8.w,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              width: 329.w,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTexts.verifyEmail,
                                    textAlign: TextAlign.start,
                                    style: AppTextStyle.headerH3(
                                        color: AppColors.white,
                                        letterSpacing: -0.1,
                                        lineHeight: 1),
                                  ),
                                  SizedBox(height: 11.h),
                                  Text(
                                    AppTexts.enterEmailCode,
                                    style: AppTextStyle.bodyRegular(
                                        color: AppColors.white,
                                        letterSpacing: 0),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40.h),
                            SizedBox(
                              width: 152.w,
                              height: 40.h,
                              child: CustomPinInput(
                                autoFocus: true,
                                length: 4,
                                otpController: otpController,
                                onChanged: (p0) {
                                  setState(() {
                                    isOtpInputStarted = p0.isNotEmpty;
                                  });
                                },
                                onCompleted: (value) async {
                                  if (widget.isForPasswordChange == true) {
                                    final signInController =
                                        Get.find<SignInController>();

                                    final flag = await signInController
                                        .verifyOtpForForgotPassword(
                                            widget.userEmail.isNotEmpty
                                                ? widget.userEmail
                                                : signInController.email.value,
                                            otpController.text.trim());
                                    if (flag) {
                                      Navigator.of(context).push(
                                          createCustomPageRoute(
                                              ChangePassword(
                                                userEmail:
                                                    widget.userEmail.isNotEmpty
                                                        ? widget.userEmail
                                                        : signInController
                                                            .email.value,
                                              ),
                                              fade: true,
                                              duration:
                                                  Duration(milliseconds: 250)));
                                    }
                                  } else {}
                                },
                              ),
                            ),
                            SizedBox(height: 48.h),
                            Obx(() {
                              if (widget.isForPasswordChange == true) {
                                final signInController =
                                    Get.find<SignInController>();
                                isChangePassOtpValidated(signInController);
                                return ResendCodeAnimatorText(
                                  isOtpInputStarted: isOtpInputStarted,
                                  isOtpInvalid: signInController
                                      .isChangePassOtpInvalid.value,
                                  onTap: () async {
                                    HapticFeedbacks.vibrate(
                                        FeedbackTypes.light);
                                    signInController
                                        .requestOtpForForgotPassword(
                                            widget.userEmail.isNotEmpty
                                                ? widget.userEmail
                                                : signInController.email.value);
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            })
                          ]),
                    ),
                  ),
                  SizedBox(height: 35.h),
                ],
              ),
            ),
            Obx(() {
              if (widget.isForPasswordChange != null) {
                final signInController = Get.find<SignInController>();
                return signInController.isLoading.value
                    ? Positioned.fill(
                        child: Container(
                          height: 1852.h,
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
              } // Hide if not loading
            }),
          ],
        ),
      ),
    );
  }

  isChangePassOtpValidated(SignInController signInController) {
    // signInController.isChangePassOtpInvalid.value = true;
    if (signInController.isChangePassOtpInvalid.value) {
      Future.delayed(const Duration(seconds: 1), () {
        signInController.isChangePassOtpInvalid.value = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            isOtpInputStarted = false;
            otpController.clear();
          });
        });
      });
    } else {}
  }
}
