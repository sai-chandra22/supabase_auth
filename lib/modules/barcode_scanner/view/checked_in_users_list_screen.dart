import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/cards/checkin_user_card.dart';
import 'package:mars_scanner/common/textfields/search_user_field.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../common/icons/icon_button.dart';
import '../../../helpers/custom_snackbar.dart';
import '../../../helpers/meeting_list_dropdown.dart';
import '../../../helpers/network.dart';
import '../../../helpers/shimmer_container.dart';
import '../../../themes/app_text_theme.dart';
import '../../../utils/asset_constants.dart';
import '../../../utils/colors.dart';
import '../../home_screen/controller/home_controller.dart';
import '../../home_screen/view/home_screen.dart';
import '../controller/barcode_scanner_controller.dart';
import '../model/event_user_model.dart';

class CheckedInUsersListScreen extends StatefulWidget {
  const CheckedInUsersListScreen({
    super.key,
    required this.onTap,
    this.isFromHomeScreen,
  });

  final void Function() onTap;
  final bool? isFromHomeScreen;

  @override
  State<CheckedInUsersListScreen> createState() =>
      _CheckedInUsersListScreenState();
}

class _CheckedInUsersListScreenState extends State<CheckedInUsersListScreen> {
  final scrollController = ScrollController();
  final homeController = Get.find<HomeController>();
  final barcodeController = Get.find<BarcodeScannerController>();
  bool _isRefreshing = false;
  bool scrollStatus = false;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMeetingList();

      scrollController.addListener(() {
        if (scrollController.hasClients) {
          double offset = scrollController.position.pixels;
          prints("offset: $offset");

          if (scrollController.position.pixels <=
              (Platform.isIOS ? -120 : -40)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                scrollStatus = true;
              });
              _onRefresh();
            });
          }
        }
      });
    });
  }

  @override
  void dispose() {
    // Properly dispose controllers to prevent memory leaks
    scrollController.dispose();
    refreshController.dispose();
    super.dispose();
  }

  fetchMeetingList() async {
    if (homeController.meetingsList.isEmpty &&
        homeController.isListLoading.value == false) {
      await homeController.getMeetingsList();
    } else {}
  }

  Future<void> _onRefresh() async {
    // Check for internet connectivity
    if (_isRefreshing) {
      return;
    }

    _isRefreshing = true; // Mark as refreshing

    final NetworkManager networkManager = NetworkManager();
    if (!(networkManager.isConnected.value)) {
      await Future.delayed(Duration(milliseconds: 2000), () {
        showCustomSnackbar(
            'No internet', 'Please check your internet connectivity');
        setState(() {
          scrollStatus = false;
        });
      });
      _isRefreshing = false;
      refreshController.refreshCompleted();
      return;
    }

    await Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        scrollStatus = false;
      });

      barcodeController.getCheckedInUsers(barcodeController.category.value);
    });
    _isRefreshing = false;
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.w, 20.h, 0.w, 0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height:
                        barcodeController.isSearchActive.value ? 54.h : 48.h,
                  );
                }),
                Padding(
                  padding: EdgeInsets.only(left: 24.w),
                  child: Baseline(
                    baseline: 28.h,
                    baselineType: TextBaseline.alphabetic,
                    child: Text("CHECKED IN GUESTS",
                        style: AppTextStyle.headerH1Brand(
                          color: Colors.white,
                          lineHeight: 1,
                          letterSpacing: 0,
                        )),
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: Platform.isAndroid
                      ? SmartRefresher(
                          enablePullUp: true,
                          cacheExtent: 500,
                          controller: refreshController,
                          footer: CustomFooter(
                            builder: (BuildContext context, LoadStatus? mode) {
                              return Container();
                            },
                          ),
                          onRefresh: _onRefresh,
                          child: checkInUsersContent(barcodeController))
                      : checkInUsersContent(barcodeController),
                ),
              ],
            ),
            Obx(() {
              final active = barcodeController.isSearchActive.value;
              // calculate how wide you want the field (screen width minus your horizontal padding)
              final totalWidth = ScreenUtil().screenWidth - 2 * 24.w;
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 2.h, 24.w, 0),
                    child: IgnorePointer(
                      ignoring: active,
                      child: AnimatedOpacity(
                        opacity: active ? 0 : 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              debugPrint(
                                  'category: ${barcodeController.selectedCategory.value}');
                              return CategoryDropDown();
                            }),
                            SizedBox(width: 1.w),
                            Transform.translate(
                              offset: Offset(0, 0.5.h),
                              child: CustomIconButton(
                                width: 20.w,
                                height: 20.h,
                                icon: AppAssets.search,
                                onTap: () {
                                  barcodeController.toggleSearch();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    margin: EdgeInsets.only(left: 0.w),
                    width: active ? totalWidth : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: active
                        ? Transform.translate(
                            offset: Offset(0, -10.h),
                            child: Row(
                              children: [
                                // you can wrap in Expanded so the TextField fills all available space
                                Expanded(
                                  child: SearchUserField(
                                    searchController: barcodeController,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget checkInUsersContent(BarcodeScannerController controller) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 0.h),
            duration: Duration(milliseconds: 300), // Duration for the animation
            curve: Curves
                .easeInOut, // Optional: Use a curve for a smooth animation
            height: scrollStatus ? 60.h : 0.h, // Animate between heights
            width: 400.w,
            child: Visibility(
              visible: scrollStatus,
              child: CupertinoActivityIndicator(
                radius: 12.r,
                color: AppColors.white,
              ),
            ),
          ),
          Obx(() {
            if ((!controller.isCheckInUsersLoading.value) &&
                (!homeController.isListLoading.value) &&
                (controller.checkedInUsers.isEmpty)) {
              return controller.checkedInUsers.isEmpty
                  ? Container(
                      width: 393.w,
                      height: 600.h,
                      alignment: Alignment.center,
                      child: Text(
                        'No checked-in Guests found',
                        style: AppTextStyle.bodySmall(color: AppColors.grey),
                      ),
                    )
                  : SizedBox();
            } else {
              final query = controller.searchQuery.value.trim().toLowerCase();
              final filteredUsers = query.isEmpty
                  ? controller.checkedInUsers
                  : controller.checkedInUsers.where((user) {
                      // 1. Build a single lowercase string containing both firstName and lastName
                      final firstName = (user.firstName ?? '').toLowerCase();
                      final lastName = (user.lastName ?? '').toLowerCase();
                      final fullName = '$firstName $lastName';

                      // 2. Split fullName into “words” by whitespace
                      //    (this handles cases like “Mahesh Babu” correctly, producing ["mahesh", "babu", "uppala"])
                      final words = fullName.split(RegExp(r'\s+'));

                      // 3. Return true if ANY word starts with the query
                      return words.any((word) => word.startsWith(query));
                    }).toList();
              return filteredUsers.isEmpty &&
                      controller.searchQuery.value.isNotEmpty
                  ? Container(
                      width: 393.w,
                      height: 600.h,
                      alignment: Alignment.center,
                      child: Text(
                        'No Guests found for the search',
                        style: AppTextStyle.bodySmall(color: AppColors.grey),
                      ),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 16.h,
                        );
                      },
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemCount:
                          (controller.isCheckInUsersLoading.value == true &&
                                      controller.checkedInUsers.isEmpty) ||
                                  (homeController.isListLoading.value == true &&
                                      homeController.meetingsList.isEmpty)
                              ? 2
                              : filteredUsers.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        final adjustedIndex = index;
                        final userModel =
                            controller.isCheckInUsersLoading.value == false &&
                                    controller.checkedInUsers.isNotEmpty
                                ? filteredUsers[adjustedIndex]
                                : null;

                        return controller.isCheckInUsersLoading.value ||
                                homeController.isListLoading.value
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 24.w, right: 5.w, bottom: 16.h),
                                  child: buildShimmerContainer(350.w, 140.h),
                                ),
                              )
                            : checkInUserCards(
                                index: adjustedIndex,
                                eventUserModel: userModel,
                                controller: controller,
                              );
                      });
            }
          }),
        ],
      ),
    );
  }

  Widget checkInUserCards(
      {required int index,
      required EventUserModel? eventUserModel,
      dynamic controller}) {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w),
      child: CheckListCard(eventUserModel: eventUserModel),
    );
  }
}
