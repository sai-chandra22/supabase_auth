import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/utils/colors.dart';

import '../themes/app_text_theme.dart';

void showCustomSnackbar(String title, String message, {int? duration}) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: AppTextStyle.bodyRegular(
        lineHeight: 1.2,
        letterSpacing: 0,
        color: AppColors.white,
      ),
    ),
    messageText: Text(
      message,
      style: AppTextStyle.bodyRegular(
        lineHeight: 1.2,
        letterSpacing: 0,
        color: AppColors.grey,
      ),
    ),
    snackPosition: SnackPosition.TOP,
    backgroundColor: AppColors.cardBackgroundFill100,
    borderRadius: 16.r,
    margin: EdgeInsets.all(8.r),
    padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
    duration: Duration(seconds: duration ?? 2),
    isDismissible: true,
    dismissDirection: DismissDirection.vertical,
    forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
  );
}
