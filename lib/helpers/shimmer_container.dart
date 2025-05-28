import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerContainer(double width, double height, [double? radius]) {
  return Shimmer.fromColors(
    baseColor: AppColors.cardBackgroundFill,
    highlightColor: AppColors.hintColor,
    direction: ShimmerDirection.ltr,
    child: Container(
      // margin: EdgeInsets.symmetric(vertical: 5.h),
      width: width,
      height: height,
      decoration: BoxDecoration(
        // shape: shape ?? BoxShape.rectangle,
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius ?? 16.r),
      ),
    ),
  );
}
