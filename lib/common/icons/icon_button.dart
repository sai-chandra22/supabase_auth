import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.height,
      this.width,
      this.padding});

  final String icon;
  final void Function() onTap;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        width: width ?? 22.w,
        height: height ?? 22.h,
        child: SvgPicture.asset(
          icon,
        ),
      ),
    );
  }
}
