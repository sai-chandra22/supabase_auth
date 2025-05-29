import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:get/get.dart';
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
                          SizedBox(
                            height: 24.h,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: scanResult(),
                            ),
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Scanned Code:',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                barcodeController.scannedCode.value,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
