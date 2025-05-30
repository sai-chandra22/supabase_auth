import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../themes/app_text_theme.dart';
import '../../../utils/colors.dart';
import '../../helpers/custom_text.dart';
import '../../helpers/date_formatter.dart';
import '../../helpers/status_tag.dart';
import '../../modules/barcode_scanner/model/event_user_model.dart';

class CheckListCard extends StatelessWidget {
  const CheckListCard({
    super.key,
    this.eventUserModel,
  });

  final EventUserModel? eventUserModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.cardBackgroundFill100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailsRowText(
                title: 'Name:',
                value: eventUserModel?.firstName != null
                    ? toTitleCase(
                        "${eventUserModel?.firstName} ${eventUserModel?.lastName ?? ''}")
                    : ''),
            DetailsRowText(
                title: 'Registered Guests:',
                value: eventUserModel?.registeredGuests?.isNotEmpty == true
                    ? "0${eventUserModel?.registeredGuests}"
                    : ''),
            Padding(
              padding: EdgeInsets.only(top: 0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        baseline: 12.h,
                        text: 'Check-In Time:',
                        style: AppTextStyle.bodyRegular(
                          color: AppColors.marsOrange600,
                          letterSpacing: 0,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        textAlign: TextAlign.left,
                        baseline: 11.h,
                        text: formatCheckInTime(
                            eventUserModel?.checkinTime ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyLargeBold(
                          color: AppColors.white,
                          letterSpacing: 0,
                        ).copyWith(fontSize: 12.sp),
                      ),
                    ],
                  ),
                  StatusTag(
                    tag: 'Checked-in'.toUpperCase(),
                    color: AppColors.positiveGreen,
                    isColored: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsRowText extends StatelessWidget {
  const DetailsRowText({
    super.key,
    required this.title,
    required this.value,
    this.fontSize,
  });

  final String title;
  final String value;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomText(
          baseline: 12.h,
          text: title,
          style: AppTextStyle.bodyRegular(
            color: AppColors.marsOrange600,
            letterSpacing: 0,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: CustomText(
            textAlign: TextAlign.left,
            baseline: 15.h,
            text: value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.bodyLargeBold(
              color: AppColors.white,
              letterSpacing: 0,
            ).copyWith(fontSize: fontSize ?? 16.sp),
          ),
        ),
      ],
    );
  }
}

String toTitleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(RegExp(r'\s+')) // split on whitespace
      .map((word) {
    if (word.isEmpty) return word;
    final lower = word.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }).join(' ');
}
