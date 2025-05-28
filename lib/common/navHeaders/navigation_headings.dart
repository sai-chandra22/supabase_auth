import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../themes/app_text_theme.dart';
import '../../utils/asset_constants.dart';
import '../../utils/colors.dart';

class NavigationHeaders extends StatelessWidget {
  const NavigationHeaders(
      {super.key, required this.headingText, required this.onTap});

  final String headingText;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      width: 393.w,
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Baseline(
              baseline: 10.h,
              baselineType: TextBaseline.alphabetic,
              child: Text(headingText.toUpperCase(),
                  style: AppTextStyle.eyebrowLarge(
                    color: AppColors.grey,
                    letterSpacing: 1.0,
                    lineHeight: 1,
                  )),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: SvgPicture.asset(AppAssets.chevronRight),
          ),
        ],
      ),
    );
  }
}
