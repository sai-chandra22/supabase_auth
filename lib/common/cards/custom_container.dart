import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? color;
  // final Color? borderColor;
  final double? opacity;
  final Widget? child;
  final String? image;
  final Gradient? gradient;

  const CustomContainer({
    super.key,
    this.width = 50,
    this.height,
    this.borderRadius = 1.0,
    this.color = Colors.white,
// this.borderColor = Colors.transparent,

    this.opacity = 1.0, // Default opacity is 1.0
    this.child,
    this.image,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (width != null && !width!.isNaN)
          ? width
          : 50.0, // Provide a default width if null
      height: (height != null && !height!.isNaN) ? height : null,
      decoration: BoxDecoration(
        color: color!.withOpacity(opacity!),
        borderRadius: BorderRadius.circular(borderRadius ?? 1.0),
        gradient: gradient,
        // border: Border.all(color: borderColor!)
      ),
      child: child,
    );
  }
}
