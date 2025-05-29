import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/themes/app_text_theme.dart';

import '../../utils/colors.dart';

class CustomTextButton extends StatefulWidget {
  final String text;
  final Color? backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool? isActive; // Optional isActive property
  final bool? isOutlineType;
  final double? height;
  final double? width;
  final double? outlineHeight;
  final double? outlineWidth;
  final TextStyle? style;
  final Color? inactiveColor;
  final bool? changeFont;
  final Color? inactiveTextColor;
  final Color? outlineColor;
  final double? outlineThickness;
  final double? fontSize;

  const CustomTextButton(
      {super.key,
      required this.text,
      this.backgroundColor,
      required this.textColor,
      required this.onPressed,
      this.isActive,
      this.isOutlineType,
      this.height,
      this.width,
      this.outlineHeight,
      this.outlineWidth,
      this.style,
      this.inactiveColor,
      this.changeFont,
      this.inactiveTextColor,
      this.outlineColor,
      this.outlineThickness,
      this.fontSize // Optional parameter
      });

  @override
  CustomTextButtonState createState() => CustomTextButtonState();
}

class CustomTextButtonState extends State<CustomTextButton>
    with SingleTickerProviderStateMixin {
  double _scaleHeight = 1.0;
  double _scaleFontSize = 1.0;

  @override
  Widget build(BuildContext context) {
    // Determine if the button should be active or not
    bool isButtonActive =
        widget.isActive ?? true; // Default to active if isActive is null

    return GestureDetector(
      onTapDown: isButtonActive
          ? (details) {
              setState(() {
                _scaleHeight = 0.97; // Slightly reduce the height
                _scaleFontSize = 0.97; // Slightly reduce the font size
              });
            }
          : null, // No action if the button is inactive
      onTapUp: isButtonActive
          ? (details) {
              setState(() {
                _scaleHeight = 1.0;
                _scaleFontSize = 1.0;
              });
              widget.onPressed();
            }
          : null, // No action if the button is inactive
      onTapCancel: isButtonActive
          ? () {
              setState(() {
                _scaleHeight = 1.0;
                _scaleFontSize = 1.0;
              });
            }
          : null, // No action if the button is inactive
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 1.0, end: _scaleHeight),
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return widget.isOutlineType == true
              ? Container(
                  width: widget.outlineWidth ?? 360.w, // Fixed width
                  height: widget.outlineHeight ?? 56.h * value, // Scaled height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36.r),
                    border: Border.all(
                      color: isButtonActive
                          ? (widget.outlineColor ?? AppColors.marsOrange600)
                          : (widget.outlineColor?.withOpacity(0.28) ??
                              AppColors.marsOrange600.withOpacity(0.28)),
                      width: widget.outlineThickness ?? 2.w,
                    ),
                  ),
                  padding: const EdgeInsets.all(1), // Padding to create space
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 2.h),
                      height: widget.height ?? 48.h * value, // Scaled height
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ??
                            Colors.black, // Button background color
                        borderRadius: BorderRadius.circular(36.r),
                      ),
                      child: Center(
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 1.0, end: _scaleFontSize),
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          builder: (context, double fontSizeValue, child) {
                            return Text(
                              widget.text,
                              style: widget.changeFont == true
                                  ? AppTextStyle.eyebrowLarge(
                                      color: isButtonActive
                                          ? widget.textColor
                                          : widget.inactiveTextColor ??
                                              AppColors.hintColor,
                                      letterSpacing: -0.1,
                                    ).copyWith(
                                      fontSize: widget.fontSize ??
                                          12.sp * fontSizeValue)
                                  : widget.style ??
                                      AppTextStyle.buttonCTAH1(
                                        color: isButtonActive
                                            ? widget.textColor
                                            : widget.inactiveTextColor ??
                                                AppColors.white,
                                        letterSpacing: -0.1,
                                      ).copyWith(
                                          fontSize: widget.fontSize ??
                                              12.sp *
                                                  fontSizeValue), // Scaled font size
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  // width: 344.w, // Standard button width (non-outline)
                  // height: 48.h * value, // Scaled height for standard button
                  width: widget.width ?? 344.w, // Fixed width
                  height: widget.height ?? 48.h * value, // Scaled height
                  decoration: BoxDecoration(
                    color: isButtonActive
                        ? widget.backgroundColor ?? AppColors.marsOrange600
                        : AppColors.hintColor, // Filled button background
                    borderRadius: BorderRadius.circular(36.r),
                  ),
                  child: Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 1.0, end: _scaleFontSize),
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      builder: (context, double fontSizeValue, child) {
                        return Text(
                          widget.text,
                          style: widget.changeFont == true
                              ? AppTextStyle.eyebrowLarge(
                                  color: isButtonActive
                                      ? widget.textColor
                                      : widget.inactiveTextColor ??
                                          AppColors.white,
                                  letterSpacing: -0.1,
                                ).copyWith(
                                  fontSize:
                                      widget.fontSize ?? 12.sp * fontSizeValue)
                              : widget.style ??
                                  AppTextStyle.buttonCTAH1(
                                    color: isButtonActive
                                        ? widget.textColor
                                        : widget.inactiveTextColor ??
                                            AppColors.white,
                                    letterSpacing: -0.1,
                                  ).copyWith(
                                      fontSize: widget.fontSize ??
                                          12.sp *
                                              fontSizeValue), // Scaled font size
                        );
                      },
                    ),
                  ),
                );
        },
      ),
    );
  }
}
