import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../helpers/haptics.dart';
import '../../themes/app_text_theme.dart';
import '../../utils/colors.dart';
import 'dart:io';

class BorderLessTextField extends StatefulWidget {
  const BorderLessTextField({
    super.key,
    this.focusNode,
    required this.controller,
    this.isForPassword = false,
    this.onChanged,
    this.isForName,
    this.nameHint,
    this.isForNumber = false,
    this.textStyle,
    this.hintStyle,
    this.isForCenter,
    this.textAlign,
    this.prefixIcon,
    this.inputFormatters,
    this.keyboardType,
    this.prefix, // Added isForPassword argument
    this.disabled,
    this.capitalize,
  });

  final FocusNode? focusNode;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final bool isForPassword; // Boolean to control password field behavior
  final bool? isForName;
  final bool isForNumber;
  final String? nameHint;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool? isForCenter;
  final TextAlign? textAlign;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final bool? disabled;
  final bool? capitalize;

  @override
  BorderLessTextFieldState createState() => BorderLessTextFieldState();
}

class BorderLessTextFieldState extends State<BorderLessTextField> {
  bool _obscureText = true; // To toggle password visibility

  void _togglePasswordView() {
    HapticFeedbacks.vibrate(FeedbackTypes.light);
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      textCapitalization: widget.capitalize == true
          ? TextCapitalization.words
          : TextCapitalization.none,
      enabled: widget.disabled,
      inputFormatters: widget.inputFormatters ?? [],
      textAlign: widget.textAlign ?? TextAlign.start,
      autocorrect: false,
      autofillHints: null,
      onChanged: widget.onChanged,
      keyboardAppearance: Brightness.dark,
      focusNode: widget.focusNode,
      controller: widget.controller,
      cursorColor: AppColors.marsOrange500,
      cursorHeight: widget.textStyle == null
          ? Platform.isIOS
              ? 24.h
              : 26.h
          : widget.textStyle!.fontSize!.sp,
      cursorWidth: 2.w,
      obscureText:
          widget.isForPassword ? _obscureText : false, // Toggle password
      autofocus: true,
      style: widget.textStyle ??
          AppTextStyle.headerH3(
            color: AppColors.white,
            letterSpacing: -0.1,
          ),
      decoration: InputDecoration(
        prefix: widget.prefix,
        isDense: true,
        hintText: widget.isForPassword
            ? 'Password'
            : widget.nameHint ??
                'Email', // Change hint text based on the field type
        hintStyle: widget.hintStyle ??
            AppTextStyle.headerH3(
                color: AppColors.hintColor, letterSpacing: -0.1, lineHeight: 1),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isForPassword
            ? GestureDetector(
                onTap: _togglePasswordView,
                child: Container(
                  color: Colors.transparent,
                  width: 24.w,
                  height: 24.h,
                  padding: EdgeInsets.only(top: 1.h, right: 32),
                  child: IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.hintColor,
                      size: 20.sp,
                    ),
                    onPressed: () {},
                  ),
                ),
              )
            : null,

        border: InputBorder.none,
      ),
      keyboardType: widget.keyboardType ??
          (widget.isForNumber
              ? TextInputType.number
              : widget.isForPassword
                  ? TextInputType.multiline
                  : widget.isForName == true
                      ? TextInputType.name
                      : TextInputType.emailAddress),

      showCursor: true,
      textAlignVertical:
          widget.isForCenter == true ? TextAlignVertical.center : null,
    );
  }
}
