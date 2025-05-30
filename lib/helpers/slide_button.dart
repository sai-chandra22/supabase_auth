import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/themes/app_text_theme.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mars_scanner/utils/colors.dart';

import '../modules/barcode_scanner/controller/barcode_scanner_controller.dart';
import '../modules/barcode_scanner/model/event_user_model.dart';

class SlideButton extends StatefulWidget {
  const SlideButton({
    super.key,
    this.slideText,
    this.slideColor,
    this.backgroundColor,
    required this.onSlideComplete,
    required this.barcode,
    this.model,
    this.isAlreadyCheckedIn,
  });

  final String? slideText;
  final Color? slideColor;
  final Color? backgroundColor;
  final void Function() onSlideComplete;
  final String barcode;
  final EventUserModel? model;
  final bool? isAlreadyCheckedIn;

  @override
  SlideButtonState createState() => SlideButtonState();
}

class SlideButtonState extends State<SlideButton> {
  double _dragOffset = 0.0;
  final double maxDragOffset = 290.w;
  bool isSwiped = false;
  bool isApiCalled = false;
  bool isLoading = false;
  bool checkedIn = false;

  @override
  void initState() {
    if (widget.isAlreadyCheckedIn == true) {
      setCheckedIn();
    }
    super.initState();
  }

  setCheckedIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        checkedIn = true;
        _dragOffset = maxDragOffset - 10.w;
        isSwiped = true;
        isLoading = false;
      });
    });
  }

  final BarcodeScannerController barcodeScannerController =
      Get.find<BarcodeScannerController>();

  void _resetSlider() {
    setState(() {
      _dragOffset = 0;
      isSwiped = false;
    });
  }

  Future<void> _onSlideComplete() async {
    setState(() {
      isSwiped = true;
      _dragOffset = maxDragOffset - 10.w;
      isLoading = true;
    });
    _checkIn();
  }

  Future<void> _checkIn() async {
    if (isApiCalled) return;
    isApiCalled = true;

    try {
      barcodeScannerController.checkinWithBarcode(
        barcode: widget.barcode,
        model: widget.model ?? EventUserModel(),
        onSuccess: () async {
          setState(() {
            isLoading = false;
            checkedIn = true;
          });
          await Future.delayed(Duration(milliseconds: 100));
          barcodeScannerController
              .getCheckedInUsers(barcodeScannerController.category.value);
          widget.onSlideComplete();
        },
        onError: () {
          setState(() {
            isLoading = false;
            checkedIn = false;
            _resetSlider();
          });
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isApiCalled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(36.r),
          child: Container(
            width: 360.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.keyboardFill,
              borderRadius: BorderRadius.circular(36.r),
            ),
            child: Stack(
              children: [
                // sliding color fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 100.w + _dragOffset,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: widget.slideColor ??
                        (checkedIn
                            ? AppColors.graphGreen
                            : AppColors.marsOrange600),
                    borderRadius: BorderRadius.circular(36.r),
                  ),
                ),

                // drag handle
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragOffset = (_dragOffset + details.delta.dx)
                          .clamp(0.0, maxDragOffset);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragOffset >= maxDragOffset * 0.8) {
                      _onSlideComplete();
                    } else {
                      // slide not far enough → reset
                      _resetSlider();
                    }
                  },
                  child: Container(
                    height: 56.h,
                    color: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: checkedIn
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        if (checkedIn) ...[
                          Center(
                            child: Text(
                              'CHECKED IN',
                              style: AppTextStyle.eyebrowLarge(
                                color: Colors.white,
                                letterSpacing: 0.1,
                                lineHeight: 1.27,
                              ),
                            ),
                          )
                        ] else ...[
                          Text(
                            isSwiped
                                ? 'CONFIRMED'
                                : (widget.slideText ?? 'CHECK IN'),
                            style: AppTextStyle.eyebrowLarge(
                              color: Colors.white,
                              letterSpacing: 0.1,
                              lineHeight: 1.27,
                            ),
                          ),
                          Spacer(),
                          SvgPicture.asset(
                            isSwiped
                                ? AppAssets.tickButton
                                : AppAssets.swipeButton,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    width: 360.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(36.r),
                    ),
                    child: Center(
                        child: CupertinoActivityIndicator(
                      color: Colors.white,
                      radius: 10,
                    )),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (!checkedIn)
          Text(
            'Swipe to Check In'.toUpperCase(),
            style: AppTextStyle.eyebrowSmall(
                color: AppColors.white, letterSpacing: .1, lineHeight: 1),
          ),
      ],
    );
  }
}
