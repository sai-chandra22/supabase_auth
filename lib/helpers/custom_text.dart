import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText(
      {super.key,
      required this.baseline,
      required this.text,
      required this.style,
      this.textAlign,
      this.overflow,
      this.maxLines});

  final double baseline;
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Baseline(
      baseline: baseline,
      baselineType: TextBaseline.alphabetic,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
