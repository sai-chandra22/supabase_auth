// Custom GlassMorphicNavBar with navigation logic
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mars_scanner/utils/colors.dart';

class GlassMorphicNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const GlassMorphicNavBar(
      {super.key, required this.currentIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: 40.h), // Space from the bottom of the screen
      child: Container(
        width: 220,
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.dockGlassBackground,
          //  Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/svg/home.svg", height: 24, width: 24,
                      // ignore: deprecated_member_use
                      color: currentIndex == 0
                          ? AppColors.white
                          : AppColors.navGrey,
                    ),

                    // Icon(Icons.home,
                    //     color: currentIndex == 0 ? AppColors.white : AppColors.navGrey),
                    onPressed: () => onTabSelected(0),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.search, height: 24, width: 24,
                      // ignore: deprecated_member_use
                      color: currentIndex == 1
                          ? AppColors.white
                          : AppColors.navGrey,
                    ),
                    onPressed: () => onTabSelected(1),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.news, height: 24, width: 24,
                      // ignore: deprecated_member_use
                      color: currentIndex == 2
                          ? AppColors.white
                          : AppColors.navGrey,
                    ),
                    onPressed: () => onTabSelected(2),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/svg/wallet.svg", height: 24, width: 24,
                      // ignore: deprecated_member_use
                      color: currentIndex == 3
                          ? AppColors.white
                          : AppColors.navGrey,
                    ),
                    onPressed: () => onTabSelected(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
