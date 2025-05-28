import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mars_scanner/utils/colors.dart';

import '../../../../helpers/lottie_decoder.dart';
import '../../../../utils/asset_constants.dart';

class OnboardingCarouselPage2 extends StatelessWidget {
  const OnboardingCarouselPage2({
    super.key,
    required PageController pageController,
    required this.currentPage,
    required this.scrollOffset,
    required this.previousPage,
  }) : _pageController = pageController;

  final PageController _pageController;
  final int currentPage;
  final double scrollOffset;
  final int previousPage;

  @override
  Widget build(BuildContext context) {
    // final screenheight = MediaQuery.of(context).size.height;
    return Container(
      //  margin: EdgeInsets.only(top: 104.5.h),
      color: AppColors.background,
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 104.5.h,
          ),
          SvgPicture.asset(
            AppAssets.marsMarketWord,
            color: Colors.transparent,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 345.w,
            height: 484.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Lottie.asset(
                    AppAssets.onBoardingV3,
                    decoder: customDecoder,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 128.h,
          ),
        ],
      ),
    );
  }
}
