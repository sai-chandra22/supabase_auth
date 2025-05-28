import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:pinput/pinput.dart';
import 'package:mars_scanner/themes/app_text_theme.dart';

import '../../helpers/haptics.dart';

class CustomPinInput extends StatelessWidget {
  final int length; // Number of pin boxes
  final TextEditingController
      otpController; // TextEditingController for the OTP
  final void Function(String)? onCompleted;
  final FocusNode? focusNode; // Added FocusNode
  final bool? autoFocus;
  final void Function()? onTap;
  final void Function(String value)? onSubmitted;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomPinInput({
    super.key,
    required this.length, // Require the length parameter
    required this.otpController,
    this.onCompleted,
    this.focusNode,
    this.autoFocus,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.keyboardType,
    // Require the controller
  });

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 32.w, // Width of each pin box
      height: 40.h, // Height of each pin box
      textStyle: AppTextStyle.headerH3(
        letterSpacing: -1, color: AppColors.white,
        //  const Color(0xff585858)
      ),
      decoration: BoxDecoration(
        color: const Color(0xff1F1F1F).withOpacity(0.88),
        borderRadius:
            BorderRadius.circular(8.r), // Border radius for rounded corners
      ),
    );

    return Pinput(
      keyboardAppearance: Brightness.dark,
      length: length, // Number of pin boxes
      controller: otpController, // Use the passed controller
      defaultPinTheme: defaultPinTheme,
      focusNode: focusNode,
      closeKeyboardWhenCompleted: false,
      showCursor: true,
      autofocus: autoFocus ?? true,
      cursor: Container(
        margin: EdgeInsets.only(right: 8.w),
        alignment: Alignment.centerLeft,
        width: 2.w, // Cursor width
        height: 24.h, // Cursor height
        color: const Color(0xffFF4C00), // Cursor color
      ),
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: const Color(0xff1F1F1F).withOpacity(0.88),
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      preFilledWidget: Text(
        '0',
        style: AppTextStyle.headerH3(
            letterSpacing: -0.1, color: const Color(0xff585858)),
      ),
      submittedPinTheme: defaultPinTheme,
      keyboardType: keyboardType ??
          TextInputType.number, // Ensure the numeric keyboard appears
      onChanged: onChanged,
      pinAnimationType: PinAnimationType.fade, // Optional animation
      onSubmitted: onSubmitted,
      onCompleted: onCompleted,
      onTap: onTap ??
          () {
            HapticFeedbacks.vibrate(FeedbackTypes.light);
            FocusScope.of(context).requestFocus();
          },
    );
  }
}
