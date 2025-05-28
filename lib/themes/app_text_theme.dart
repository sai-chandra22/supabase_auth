import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class AppTextStyle {
  static const String spaceGrotesk = 'SpaceGrotesk';
  static const String vanguard = 'VanguardCF';
  static const String sfPro = 'SF Pro';
  static const String gilroy = 'Gilroy';

  // Eyebrow styles
  static TextStyle eyebrowXSTimestamp(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 9.sp, // Using 9.sp for scalable pixel
        color: color ?? Colors.white, // Default color as white
        height: lineHeight?.h, // Using line height if provided
        letterSpacing: letterSpacing, // Using letter spacing if provided
        decoration: TextDecoration.none, // No decoration
        textBaseline: textBaseline, // Optional TextBaseline
      );

  static TextStyle eyebrowXS(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 8.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowSmallTimestamp(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 9.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowSmall(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 9.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing ?? (9.sp * .01),
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowMedium(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 11.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing ?? (11.sp * 0.01),
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowLarge(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 12.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing ?? (12.sp * 0.01),
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowLargeBold(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w700, // Bold
        fontSize: 14.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowXL(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 14.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle eyebrowXLBold(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w700, // Bold
        fontSize: 14.sp,
        color: color ?? Colors.white,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  // Body styles
  static TextStyle bodySmall(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline,
          TextDecoration? decoration}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w400, // Regular
        fontSize: 9.5.sp,
        height: lineHeight?.h ??
            1.2.h, // Default line height is 1.2 if not provided
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: decoration ?? TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle bodySmallBold(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 13.sp,
        height: lineHeight?.h ?? 1.2.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle bodyRegular(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w400, // Regular
        fontSize: 10.sp,
        height: lineHeight?.h ?? 1.2.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle bodyRegularBold(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w700, // Bold
        fontSize: 10.sp,
        height: lineHeight?.h ?? 1.2.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle bodyLarge(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w400, // Regular
        fontSize: 12.5.sp,
        height: lineHeight?.h ?? 1.2.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle bodyLargeBold(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 16.sp,
        height: lineHeight?.h ?? 1.2.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  // Header styles
  static TextStyle headerH1Brand(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: vanguard,
        fontWeight: FontWeight.w800, // Extra Bold
        fontSize: 28.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        decoration: TextDecoration.none,
        color: color ?? Colors.white,
        textBaseline: textBaseline,
      );

  static TextStyle headerH2Brand(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: vanguard,
        fontWeight: FontWeight.w800, // Extra Bold
        fontSize: 26.sp,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH3Brand(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: vanguard,
        fontWeight: FontWeight.w800, // Extra Bold
        fontSize: 24.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH4Brand(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: vanguard,
        fontWeight: FontWeight.w800, // Extra Bold
        fontSize: 22.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH1(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 28.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH2(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 18.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH3(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 16.5.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing ?? (16.5.sp * -0.01),
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH4(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 14.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing ?? (14.0.sp * -0.01),
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle headerH5(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w500, // Medium
        fontSize: 16.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  // Button CTA styles
  static TextStyle buttonCTAH1(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w400, // Bold
        fontSize: 12.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle buttonCTAH1Pressed(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w700, // Bold
        fontSize: 12.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle buttonCTAH2(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w700, // Bold
        fontSize: 10.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle buttonCTAH2Pressed(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: spaceGrotesk,
        fontWeight: FontWeight.w700, // Bold
        fontSize: 15.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle buttonSFPro(
          {Color? color,
          double? lineHeight,
          double? letterSpacing,
          TextBaseline? textBaseline}) =>
      TextStyle(
        fontFamily: sfPro,
        fontWeight: FontWeight.w700, // Semi Bold
        fontSize: 19.sp,
        height: lineHeight?.h,
        letterSpacing: letterSpacing,
        color: color ?? Colors.white,
        decoration: TextDecoration.none,
        textBaseline: textBaseline,
      );

  static TextStyle publicationtext() => TextStyle(
        fontFamily: gilroy,
        fontWeight: FontWeight.w900,
        fontSize: 10.5.sp * 1.2,
        color: Color(0xffc9c9c9),
        decoration: TextDecoration.none,
        letterSpacing: -0.06,
      );
}
