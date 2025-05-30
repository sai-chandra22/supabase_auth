import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/helpers/shimmer_container.dart';
import 'package:mars_scanner/modules/barcode_scanner/controller/barcode_scanner_controller.dart';

import '../../helpers/haptics.dart';
import '../../modules/home_screen/controller/home_controller.dart';
import '../../themes/app_text_theme.dart';
import '../../utils/colors.dart';

class CategoryDropDown extends StatefulWidget {
  const CategoryDropDown({super.key, this.selectedCategory});

  final String? selectedCategory;

  @override
  CategoryDropDownState createState() => CategoryDropDownState();
}

class CategoryDropDownState extends State<CategoryDropDown> {
  String? selectedOption;
  bool isDropdownOpen = false;
  final barcodeController = Get.find<BarcodeScannerController>();
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    debugPrint('35ssd: ${barcodeController.selectedCategory.value}');
    // Set initial selected option to the first key in rssFeedData
    if (barcodeController.selectedCategory.value.isNotEmpty) {
      selectedOption = barcodeController.selectedCategory.value;
    } else {
      selectedOption = 'ehp50ve2dkgux1h54fk08ecx'; // Default to Industry News

      if (homeController.meetingsList.isNotEmpty) {
        // Ensure 'Industry News' is selected if it exists in the data
        selectedOption = homeController.meetingsList.keys
                .contains('2025 Mars Shareholder Meeting')
            ? '2025 Mars Shareholder Meeting'
            : homeController.meetingsList.keys.first;
      }
      barcodeController.selectedCategory.value =
          selectedOption ?? '2025 Mars Shareholder Meeting';
    }
  }

  void toggleDropdown() {
    HapticFeedbacks.vibrate(FeedbackTypes.light);
    setState(() {
      isDropdownOpen = !isDropdownOpen;
    });
  }

  void selectOption(String key) {
    setState(() {
      selectedOption = key;
      isDropdownOpen = false;
      barcodeController.selectedCategory.value = key;

      // Update category with the value (ID) from rssFeedData
      barcodeController.updateCategory(homeController.meetingsList[key]!);
      fetchCheckInList(barcodeController);
    });
  }

  fetchCheckInList(BarcodeScannerController controller) {
    controller.getCheckedInUsers(controller.category.value);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final options = homeController.meetingsList;
      if (options.isEmpty && homeController.isListLoading.value) {
        return buildShimmerContainer(100.w, 24.h); // Shimmer();
      } else if (options.isEmpty) {
        return SizedBox(); // Return empty widget if no data
      }

      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        GestureDetector(
          onTap: toggleDropdown,
          child: Container(
            margin: EdgeInsets.only(left: options.length * 2.5),
            padding: EdgeInsets.only(left: 8.h, right: 8.h),
            height: 22.h,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white),
              color: AppColors.cardBackgroundFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                barcodeController.selectedCategory.value.isNotEmpty
                    ? barcodeController.selectedCategory.value.toUpperCase()
                    : selectedOption?.toUpperCase() ??
                        '2025 MARS SHAREHOLDER MEETING',
                style: AppTextStyle.eyebrowMedium(color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Transform.translate(
          offset: Offset(-10, 0),
          child: AnimatedContainer(
            height: isDropdownOpen
                ? options.length == 1
                    ? 60.h
                    : options.length * 42.h
                : 0,
            width: 240, // Wider to accommodate longer category names
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ClipRect(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: AppColors.cardBackgroundFill,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    String key = options.keys.elementAt(index);
                    return GestureDetector(
                      onTap: () => selectOption(key),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                        color: (barcodeController
                                        .selectedCategory.value.isNotEmpty
                                    ? barcodeController.selectedCategory.value
                                        .toUpperCase()
                                    : selectedOption?.toUpperCase()) ==
                                key.toUpperCase()
                            ? AppColors.cardBackgroundFill
                            : Colors.transparent,
                        child: Text(
                          key.toUpperCase(),
                          style: AppTextStyle.eyebrowMedium(
                            color: (barcodeController
                                            .selectedCategory.value.isNotEmpty
                                        ? barcodeController
                                            .selectedCategory.value
                                            .toUpperCase()
                                        : selectedOption?.toUpperCase()) ==
                                    key.toUpperCase()
                                ? AppColors.hintColor
                                : Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ]);
    });
  }
}
