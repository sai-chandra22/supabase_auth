import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mars_scanner/helpers/shimmer_container.dart';
import 'package:mars_scanner/helpers/slide_button.dart';
import 'package:mars_scanner/modules/barcode_scanner/model/event_user_model.dart';

import 'package:mars_scanner/themes/app_text_theme.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:get/get.dart';

import '../../../common/cards/checkin_user_card.dart';
import '../controller/barcode_scanner_controller.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  final BarcodeScannerController barcodeController =
      Get.put(BarcodeScannerController());
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! > 0 &&
            details.velocity.pixelsPerSecond.dx > 150) {
          Navigator.pop(context);
        }
      },
      child: Obx(() {
        return Scaffold(
          appBar: barcodeController.scannedCode.isEmpty
              ? AppBar(
                  centerTitle: true,
                  title: const Text('Scan Barcode',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: AppColors.background,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: barcodeController.scannedCode.isEmpty
                      ? [
                          IconButton(
                            color: Colors.white,
                            icon:
                                const Icon(Icons.flash_on, color: Colors.white),
                            onPressed: () => controller.toggleTorch(),
                          ),
                          IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.cameraswitch,
                                color: Colors.white),
                            onPressed: () => controller.switchCamera(),
                          ),
                        ]
                      : [],
                )
              : null,
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              Expanded(
                child: Obx(() {
                  // If there's no scanned code, show the scanner
                  if (barcodeController.scannedCode.isEmpty) {
                    return MobileScanner(
                      controller: controller,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code =
                              barcodes.first.rawValue ?? 'Unknown';
                          // Update the controller with the scanned code
                          barcodeController.updateScannedCode(code);
                          // Stop scanning after getting a result
                          controller.stop();
                        }
                      },
                      onDetectError: (error, stackTrace) {
                        debugPrint('95ssd Error: $error');
                      },
                    );
                  } else {
                    // If there's a scanned code, show the result screen
                    return Padding(
                      padding: EdgeInsets.fromLTRB(0.w, 66.h, 0.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 22.w),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: SvgPicture.asset(
                                    AppAssets.chevronLeft,
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Expanded(
                            child: scanResult(),
                          )

                          // No 'Scan Again' button as per requirements
                        ],
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
        );
      }),
    );
  }

  scanResult() {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: 0.w),
                child: Baseline(
                  baseline: 28.h,
                  baselineType: TextBaseline.alphabetic,
                  child: Text("SCAN RESULT",
                      style: AppTextStyle.headerH1Brand(
                        color: Colors.white,
                        lineHeight: 1,
                        letterSpacing: 0,
                      )),
                ),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            // CheckListCard(),
            Container(
              width: double.infinity,
              padding: barcodeController.isLoading.value
                  ? EdgeInsets.zero
                  : EdgeInsets.all(16.sp) + EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColors.cardBackgroundFill.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: barcodeController.isLoading.value
                  ? loadingScanResult()
                  : barcodeController.isValidBarcode.value
                      ? verifiedScanResult(
                          barcodeController.eventUserData.value)
                      : unverifiedResult(),
            ),
          ],
        ),
      );
    });
  }

  Column unverifiedResult() {
    return Column(
      spacing: 20.h,
      children: [
        SizedBox(height: 0.h),
        Center(
          child: Text(
            'INVALID DETAILS'.toUpperCase(),
            style: AppTextStyle.bodyLargeBold(
              color: AppColors.marsOrange600,
              letterSpacing: 0,
            ).copyWith(
              fontSize: 16.sp,
            ),
          ),
        ),
        Center(
          child: Text(
            textAlign: TextAlign.center,
            'Barcode is not valid or RSVP not completed'.toUpperCase(),
            style: AppTextStyle.bodyRegular(
              color: AppColors.white,
              letterSpacing: 0,
            ).copyWith(
                // fontSize: 16.sp,
                ),
          ),
        ),
        Container(
          width: double.infinity,
          color: AppColors.white,
          padding: EdgeInsets.all(16.sp),
          child: Stack(
            alignment: Alignment.center,
            children: [
              bw.BarcodeWidget(
                barcode: bw.Barcode.code128(), // ← Code-128
                data: barcodeController
                    .scannedCode.value, // ← the ID you get back from your API

                height: 60.h,
                drawText: false, // we just want the bars
              ),
              Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    AppAssets.unverified,
                    width: 240.h,
                    height: 70.h,
                  ))
            ],
          ),
        ),
        SizedBox(height: 0.h),
      ],
    );
  }

  Column loadingScanResult() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: buildShimmerContainer(double.infinity, 300.h),
            ),
            LoadingOverlayWidget(),
          ],
        ),
      ],
    );
  }

  Column verifiedScanResult(EventUserModel? eventUserModel) {
    return Column(
      spacing: 20.h,
      children: [
        Center(
          child: Text(
            'Guest Details'.toUpperCase(),
            style: AppTextStyle.bodyLargeBold(
              color: AppColors.marsOrange600,
              letterSpacing: 0,
            ).copyWith(
              fontSize: 16.sp,
            ),
          ),
        ),
        SizedBox(height: 0.h),
        DetailsRowText(
            icon: Icons.person,
            value: eventUserModel?.firstName != null
                ? toTitleCase(
                    "${eventUserModel?.firstName} ${eventUserModel?.lastName ?? ''}")
                : 'John Doe',
            fontSize: 18.sp),
        if (eventUserModel?.phoneNumber?.isNotEmpty == true)
          DetailsRowText(
              icon: Icons.phone,
              value: eventUserModel?.phoneNumber ?? '',
              fontSize: 18.sp),
        DetailsRowText(
            icon: Icons.group,
            value: eventUserModel?.registeredGuests?.isNotEmpty == true
                ? "0${eventUserModel?.registeredGuests}"
                : '',
            fontSize: 18.sp),
        Container(
          width: double.infinity,
          color: AppColors.white,
          padding: EdgeInsets.all(16.sp),
          child: Stack(
            alignment: Alignment.center,
            children: [
              bw.BarcodeWidget(
                barcode: bw.Barcode.code128(), // ← Code-128
                data: barcodeController
                    .scannedCode.value, // ← the ID you get back from your API

                height: 60.h,
                drawText: false, // we just want the bars
              ),
              Opacity(
                  opacity: 0.6,
                  child: Image.asset(AppAssets.verified,
                      width: 40.h, height: 40.h))
            ],
          ),
        ),
        SlideButton(
          barcode: barcodeController.scannedCode.value,
          model: barcodeController.eventUserData.value,
          isAlreadyCheckedIn: barcodeController.isAlreadyCheckedIn.value,
          onSlideComplete: () {},
        ),
      ],
    );
  }
}

class LoadingOverlayWidget extends StatefulWidget {
  const LoadingOverlayWidget({super.key});

  @override
  KYCOverlayWidgetState createState() => KYCOverlayWidgetState();
}

class KYCOverlayWidgetState extends State<LoadingOverlayWidget> {
  // This flag determines which text is shown.
  bool showFirstText = true;

  @override
  void initState() {
    super.initState();

    // After a delay, switch to the second text with AnimatedSwitcher.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          showFirstText = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoActivityIndicator(
          radius: 12.r,
          color: AppColors.white,
        ),
        const SizedBox(height: 20),
        // Use AnimatedSwitcher to switch the text with a fade effect.
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: showFirstText
              ? Text(
                  "Validating the barcode, Please wait......",
                  key: const ValueKey(1),
                  style: AppTextStyle.bodyRegular(color: AppColors.white),
                )
              : Text(
                  "Almost there.....",
                  key: const ValueKey(2),
                  style: AppTextStyle.bodyRegular(
                      color:
                          showFirstText ? Colors.transparent : AppColors.white),
                ),
        ),
      ],
    );
  }
}
