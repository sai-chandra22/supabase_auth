import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller/signin_controller.dart';
import '../../../utils/colors.dart';
import '../../../themes/app_text_theme.dart';
import '../../../common/buttons/custom_button.dart';
import '../../../common/textfields/custom_textfield_widget.dart';
import '../../../common/textfields/otp_field.dart';
import '../../../helpers/haptics.dart';
import 'simple_home_screen.dart';

class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final signInController = Get.find<SignInController>();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();
  bool showOtpField = false;

  @override
  void initState() {
    super.initState();
    signInController.clearAllFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(emailFocusNode);
    });
  }

  @override
  void dispose() {
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    otpFocusNode.dispose();
    super.dispose();
  }

  void _handleSendOtp() async {
    if (signInController.isEmailValid.value &&
        signInController.isPasswordValid.value) {
      HapticFeedbacks.vibrate(FeedbackTypes.light);
      signInController.storeEmail(signInController.emailController.text.trim());

      final success = await signInController.sendOtpForSignIn(
        signInController.provider != 'supabase_email_password'
            ? signInController.email.value
            : signInController.emailController.text.trim(),
        signInController.passwordController.text.trim(),
      );

      if (success) {
        setState(() {
          showOtpField = true;
        });

        // Focus on OTP field after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          FocusScope.of(context).requestFocus(otpFocusNode);
        });
      }
    }
  }

  void _handleVerifyOtp() async {
    final success = await signInController.verifySignInOtp();

    if (success) {
      // Navigate to home screen
      Get.off(() => const SimpleHomeScreen());
      await signInController.setUserData();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 60.h),
                  Text(
                    'Welcome Back',
                    style: AppTextStyle.headerH2(
                        color: Colors.white, letterSpacing: -0.1),
                  ),
                  SizedBox(height: 40.h),

                  // Email field
                  CustomTextField(
                    hintText: 'Your Email',
                    textController: signInController.emailController,
                    focusNode: emailFocusNode,
                    onChanged: (_) {
                      signInController.validateEmail();
                    },
                    onSubmitted: (_) {
                      FocusScope.of(context).requestFocus(passwordFocusNode);
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Password field
                  CustomTextField(
                    hintText: 'Your Password',
                    textController: signInController.passwordController,
                    focusNode: passwordFocusNode,
                    isForPassword: true,
                    onChanged: (_) {
                      signInController.validatePassword();
                    },
                    onSubmitted: (_) {
                      if (!showOtpField) {
                        _handleSendOtp();
                      }
                    },
                  ),

                  SizedBox(height: 20.h),

                  // OTP field (conditionally shown)
                  if (showOtpField) ...[
                    SizedBox(height: 20.h),
                    Text(
                      'Enter the verification code',
                      style: AppTextStyle.bodyRegular(color: Colors.white),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: SizedBox(
                        width: 192.w,
                        height: 40.h,
                        child: CustomPinInput(
                          focusNode: otpFocusNode,
                          length: 4,
                          otpController: signInController.otpController,
                          onChanged: (value) {
                            if (value.length == 4) {
                              setState(() {});
                            }
                            signInController
                                .isUserInputOtp(signInController.otpController);
                          },
                          onCompleted: (value) {
                            _handleVerifyOtp();
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    TextButton(
                      onPressed: () {
                        _handleSendOtp();
                      },
                      child: Text(
                        'Resend Code',
                        style: AppTextStyle.bodyRegular(
                            color: AppColors.marsOrange600),
                      ),
                    ),
                  ],

                  SizedBox(height: 40.h),

                  // Login button
                  Obx(() {
                    return CustomTextButton(
                      isActive: showOtpField
                          ? signInController.otpController.text.length == 4
                          : signInController.isEmailValid.value &&
                              signInController.isPasswordValid.value,
                      text: showOtpField ? 'LOGIN' : 'SEND OTP',
                      backgroundColor: AppColors.marsOrange600,
                      textColor: Colors.white,
                      onPressed: () {
                        if (showOtpField) {
                          _handleVerifyOtp();
                        } else {
                          _handleSendOtp();
                        }
                      },
                    );
                  }),
                ],
              ),
              Obx(() {
                return signInController.isLoading.value
                    ? Container(
                        color: Colors.black.withOpacity(0.5),
                        // margin: EdgeInsets.only(top: 20.h),
                        child: CupertinoActivityIndicator(
                          radius: 10.r,
                          color: Colors.white,
                        ),
                      )
                    : SizedBox(height: 20.h);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
