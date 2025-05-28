import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/modules/onboarding/controller/signin_controller.dart';

import '../../themes/app_text_theme.dart';
import '../../utils/app_texts.dart';
import '../../utils/colors.dart';

class ResendCodeAnimatorText extends StatelessWidget {
  const ResendCodeAnimatorText(
      {super.key,
      required this.isOtpInputStarted,
      required this.isOtpInvalid,
      required this.onTap,
      this.isForSignIn});

  final bool isOtpInputStarted;
  final bool isOtpInvalid;
  final void Function()? onTap;
  final bool? isForSignIn;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSlide(
          offset: isOtpInputStarted
              ? isForSignIn == null
                  ? Offset(0, 3)
                  : Offset(0, 1)
              : Offset(0, 0), // Slide down when typing
          duration: Duration(milliseconds: 150),
          child: AnimatedOpacity(
            opacity:
                isOtpInputStarted ? 0.0 : 1.0, // Fade out when typing starts
            duration: Duration(milliseconds: 120),
            child: isForSignIn == null
                ? resendText(onTap)
                : resendSignInText(onTap),
          ),
        ),
        AnimatedSlide(
          offset: isOtpInvalid
              ? Offset(0, 0)
              : Offset(0, 4), // Slide up to show error
          duration: Duration(milliseconds: 150),
          child: AnimatedOpacity(
            opacity: isOtpInvalid ? 1.0 : 0.0, // Fade in/out the error message
            duration: Duration(milliseconds: 120),
            child: Container(
              width: double.infinity,
              padding: isForSignIn == null
                  ? EdgeInsets.zero
                  : EdgeInsets.only(top: 10.h),
              alignment:
                  isForSignIn == null ? Alignment.centerLeft : Alignment.center,
              child: Baseline(
                baseline: 10.h,
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  AppTexts.incorrectCode,
                  style: AppTextStyle.bodyRegular(
                      color: AppColors.red, letterSpacing: 0, lineHeight: 1.2),
                  textAlign: TextAlign.center, // Red error message
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget resendText(void Function()? onTap) {
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
            onTap: onTap,
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

  Widget resendSignInText(void Function()? onTap) {
    final signInController = Get.find<SignInController>(); // SignInController
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.enterVerification,
              style: AppTextStyle.bodyRegular(
                  lineHeight: 1.2, color: AppColors.grey),
            ),
            SizedBox(width: 4.w),
            Text(
              maskNumber(signInController.registeredNumber.value),
              style: AppTextStyle.bodyRegular(
                  lineHeight: 1.2, color: AppColors.grey),
            ),
          ],
        ),
        SizedBox(height: 40.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTexts.receiveCodeQtn,
              textAlign: TextAlign.start,
              style: AppTextStyle.bodyRegular(
                color: AppColors.hintColor,
                letterSpacing: 0,
              ),
            ),
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: onTap,
              child: Text(
                AppTexts.resend,
                style: AppTextStyle.bodyRegularBold(
                        color: AppColors.grey, letterSpacing: 0)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String maskNumber(String numStr) {
    if (numStr.length <= 2) {
      return numStr; // If the number has 2 or fewer digits, return it as is
    }
    String masked = '*' * (numStr.length - 2); // Mask all but the last 2 digits
    return masked +
        numStr.substring(numStr.length - 2); // Append the last 2 digits
  }
}
