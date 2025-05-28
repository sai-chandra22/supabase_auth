import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/helpers/haptics.dart';

import '../themes/app_text_theme.dart';
import '../utils/colors.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No Internet Connection',
            style: AppTextStyle.headerH4(
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Please check your connection and try again',
            style: AppTextStyle.eyebrowXS(
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              HapticFeedbacks.vibrate(FeedbackTypes.light);
              //  homeController2?.onInit(); // Retry loading data
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.marsOrange600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 6.h,
              ),
            ),
            child: Text(
              'RETRY',
              style: AppTextStyle.buttonCTAH2Pressed(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
