import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../themes/app_text_theme.dart';
import '../utils/colors.dart';

class StatusTag extends StatefulWidget {
  const StatusTag({
    super.key,
    this.tag,
    this.isColored,
    this.height,
    this.width,
    this.color,
    this.isForNotification,
  });

  final String? tag;
  final bool? isColored;
  final double? height;
  final double? width;
  final Color? color;
  final bool? isForNotification;

  @override
  State<StatusTag> createState() => _StatusTagState();
}

class _StatusTagState extends State<StatusTag> {
  final ValueNotifier<bool> isTodayDate = ValueNotifier(false);

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    isTodayDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: isTodayDate,
        builder: (context, isToday, child) {
          return IntrinsicWidth(
            child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                ),
                height: widget.height ?? 15.h,
                width: widget.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: widget.isColored == true
                          ? widget.color ?? AppColors.positiveGreen
                          : isToday == true
                              ? AppColors.white
                              : AppColors.black),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0.0, 4, 2),
                    child: Text(
                      widget.tag?.toUpperCase() ?? '',
                      style: AppTextStyle.eyebrowSmall(
                          color: widget.isColored == true
                              ? widget.color ?? AppColors.positiveGreen
                              : isToday == true
                                  ? AppColors.white
                                  : AppColors.black),
                    ),
                  ),
                )),
          );
        });
  }
}
