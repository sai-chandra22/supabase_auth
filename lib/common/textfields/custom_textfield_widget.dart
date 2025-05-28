import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../helpers/haptics.dart';
import '../../themes/app_text_theme.dart';
import '../../utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final double borderRadius;
  final double width;
  final double height;
  final Color cursorColor;
  final Color backgroundColor;
  final FocusNode? focusNode;
  final TextEditingController? textController;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool isForPassword; // Boolean to control password field behavior
  final void Function(String)? onSubmitted;
  final bool? capitalize;
  final bool? autoFocus;
  final TextStyle? style;

  const CustomTextField(
      {super.key,
      required this.hintText,
      this.borderRadius = 8.0,
      this.width = double.infinity,
      this.height = 48.0,
      this.cursorColor = AppColors.marsOrange600,
      this.backgroundColor = AppColors.cardBackgroundFill,
      this.focusNode,
      this.textController,
      this.isForPassword = false,
      this.onChanged,
      this.inputFormatters,
      this.keyboardType,
      this.onSubmitted,
      this.capitalize,
      this.autoFocus,
      this.style});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false; // To toggle password visibility
  void _togglePasswordView() {
    HapticFeedbacks.vibrate(FeedbackTypes.light);
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isForPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: TextField(
        textCapitalization: widget.capitalize == true
            ? TextCapitalization.words
            : TextCapitalization.none,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        obscureText: _obscureText,
        autofocus: widget.autoFocus ?? true,
        autocorrect: false,
        autofillHints: null,
        keyboardAppearance: Brightness.dark,
        controller: widget.textController,
        focusNode: widget.focusNode,
        cursorColor: widget.cursorColor, // Orange cursor
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyle.headerH4(
              color: AppColors.hintColor,
              textBaseline: TextBaseline.alphabetic),
          border: InputBorder.none,
          // contentPadding: const EdgeInsets.fromLTRB(
          //     16.0, 16.0, 16.0, 16.0), // Padding inside the field
          contentPadding: EdgeInsets.fromLTRB(
              16.w,
              widget.isForPassword ? 10.h : 9.h,
              0,
              7.h), // Padding inside the field
          suffixIcon: widget.isForPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.hintColor,
                    size: 20.sp,
                  ),
                  onPressed: _togglePasswordView,
                )
              : null,
        ),
        style: const TextStyle(
            color: Colors.white, decoration: TextDecoration.none),
        onChanged: widget.onChanged, // Text color
        keyboardType: widget.keyboardType ?? TextInputType.emailAddress,
      ),
    );
  }
}
