import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../themes/app_text_theme.dart';
import '../../utils/colors.dart';

class SocialLoginButtons extends StatefulWidget {
  final String text;
  final String? iconPath; // Path to the icon (like SvgPicture asset)
  final VoidCallback onPressed; // Callback function for onPress action
  final bool? showIcon;

  const SocialLoginButtons({
    super.key,
    required this.text,
    this.iconPath,
    required this.onPressed,
    this.showIcon,
  });

  @override
  SocialLoginButtonsState createState() => SocialLoginButtonsState();
}

class SocialLoginButtonsState extends State<SocialLoginButtons> {
  double _scaleHeight = 1.0;
  double _scaleFontSize = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          _scaleHeight = 0.98; // Slightly reduce the height
          _scaleFontSize = 0.99; // Slightly reduce the font size
        });
      },
      onTapUp: (details) {
        setState(() {
          _scaleHeight = 1.0;
          _scaleFontSize = 1.0;
        });
        widget.onPressed(); // Trigger the onPress action
      },
      onTapCancel: () {
        setState(() {
          _scaleHeight = 1.0;
          _scaleFontSize = 1.0;
        });
      },
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 1.0, end: _scaleHeight),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return Container(
            width: 344.w,
            height: 48.h * value, // Animate height change
            //   margin: widget.margin ?? EdgeInsets.symmetric(horizontal: 25.5.w),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(36.r),
              border: Border.all(
                color: const Color(0xFF4D4D4D),
                width: 1, // Border width 1px
              ),
            ),
            child:
                // widget.onlyText != true
                //     ? Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 22.5.w),
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.start,
                //           crossAxisAlignment: CrossAxisAlignment.center,
                //           children: [
                //             SvgPicture.asset(widget.iconPath ?? ''),
                //             SizedBox(
                //                 width: widget.isGoogle == true ? 67.5.w : 75.5.w),
                //             TweenAnimationBuilder(
                //               tween: Tween<double>(begin: 1.0, end: _scaleFontSize),
                //               duration: const Duration(milliseconds: 100),
                //               curve: Curves.easeInOut,
                //               builder: (context, double fontSizeValue, child) {
                //                 return Text(
                //                   widget.text.toUpperCase(),
                //                   style: AppTextStyle.buttonCTAH1(
                //                     color: AppColors.white,
                //                     letterSpacing: -0.01,
                //                   ).copyWith(fontSize: 12.sp * fontSizeValue),
                //                 );
                //               },
                //             ),
                //           ],
                //         ),
                //       )
                //     :
                Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 1.0, end: _scaleFontSize),
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    builder: (context, double fontSizeValue, child) {
                      return Text(
                        widget.text.toUpperCase(),
                        style: AppTextStyle.buttonCTAH1(
                          color: AppColors.white,
                          letterSpacing: -0.01,
                        ).copyWith(fontSize: 12.sp * fontSizeValue),
                      );
                    },
                  ),
                ),
                if (widget.showIcon == true)
                  Transform.translate(
                      offset: const Offset(20, 0),
                      child: SvgPicture.asset(widget.iconPath ?? '')),
              ],
            ),
          );
        },
      ),
    );
  }
}
