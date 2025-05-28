import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mars_scanner/themes/app_text_theme.dart';

import '../common/buttons/custom_button.dart';
import '../utils/asset_constants.dart';
import '../utils/colors.dart';
import 'custom_text.dart';

class ShmCautionPopUp extends StatelessWidget {
  const ShmCautionPopUp(
      {super.key,
      this.isCancel,
      required this.onTap,
      this.isForLogOut,
      this.isForDeleteAccount,
      this.title,
      this.bodyText});

  final bool? isCancel;
  final void Function() onTap;
  final bool? isForLogOut;
  final bool? isForDeleteAccount;
  final String? title;
  final String? bodyText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 393.w,
          height: isForLogOut != null && isForLogOut == true
              ? 217.h
              : isForDeleteAccount != null && isForDeleteAccount == true
                  ? 300.h
                  : 270.h,
          padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 393.w,
                height: 24.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // HapticFeedbacks.vibrate(FeedbackTypes.light);
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: SvgPicture.asset(
                          AppAssets.crossIcon,
                          colorFilter: const ColorFilter.mode(
                            AppColors.background,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomText(
                baseline: 11.h,
                text: 'CONFIRM LOG OUT',
                style: AppTextStyle.eyebrowXL(
                    color: AppColors.background,
                    letterSpacing: 0.1,
                    lineHeight: 1),
              ),
              SizedBox(
                height: 32.h,
              ),
              Baseline(
                baseline: 10.h,
                baselineType: TextBaseline.alphabetic,
                child: Text(
                  textAlign: TextAlign.center,
                  'Are you sure you want to log out?',
                  style: AppTextStyle.bodyRegular(
                      color: AppColors.hintColor,
                      letterSpacing: 0,
                      lineHeight: 1.2),
                ),
              ),
              SizedBox(
                height: 24.h,
              ),
              CustomTextButton(
                isOutlineType: isForLogOut != null && isForLogOut == true
                    ? false
                    : isForDeleteAccount != null && isForDeleteAccount == true
                        ? false
                        : true,
                text: 'LOG OUT',
                textColor: AppColors.white,
                onPressed: onTap,
              )
            ],
          ),
        ),
      ],
    );
  }
}
