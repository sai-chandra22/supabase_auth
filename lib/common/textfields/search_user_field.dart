import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/modules/barcode_scanner/controller/barcode_scanner_controller.dart';

import '../../themes/app_text_theme.dart';
import '../../utils/app_texts.dart';
import '../../utils/asset_constants.dart';
import '../../utils/colors.dart';
import '../icons/icon_button.dart';

class SearchUserField extends StatelessWidget {
  const SearchUserField({
    super.key,
    required this.searchController,
  });

  final BarcodeScannerController searchController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.dockGlassBackground,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(36),
      ),
      child: TextField(
        textCapitalization: TextCapitalization.words,
        keyboardAppearance: Brightness.dark,
        controller: searchController.searchController,
        onChanged: (value) async {
          //  if (searchController.bookMarkController.text.length >= 3) {
          searchController.onSearchChanged();
          //  }
        },
        cursorColor: AppColors.marsOrange500,
        cursorHeight: 20.h,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 15.h),
            hintText: AppTexts.searchUserHint.toUpperCase(),
            hintStyle: AppTextStyle.eyebrowLarge(
              color: AppColors.grey.withOpacity(0.5),
              letterSpacing: 0.1,
              lineHeight: 1.27,
            ),
            filled: true,
            fillColor: AppColors.dockGlassBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Container(
              margin: EdgeInsets.only(right: 24.w, top: 15.h, bottom: 15.h),
              height: 24.h,
              width: 24.w,
              child: CustomIconButton(
                icon: AppAssets.crossIcon,
                onTap: () {
                  // HapticFeedbacks.vibrate(FeedbackTypes.soft);
                  if (searchController.searchController.text.isNotEmpty) {
                    searchController.clearSearch();
                  } else {
                    searchController.toggleSearch();
                  }
                },
              ),
            )),
        autofocus: true,
        style: AppTextStyle.bodyLargeBold(
            color: AppColors.white,
            textBaseline: TextBaseline.alphabetic,
            letterSpacing: 0,
            lineHeight: 1.2),
      ),
    );
  }
}
