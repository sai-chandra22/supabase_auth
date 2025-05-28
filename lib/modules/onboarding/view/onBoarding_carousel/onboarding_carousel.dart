import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:keyboard_detection/keyboard_detection.dart';
import 'package:mars_scanner/common/animators/heading_animation.dart';
import 'package:mars_scanner/modules/onboarding/view/onBoarding_carousel/onboarding_carousel_page4.dart';
import 'package:mars_scanner/modules/onboarding/view/onBoarding_carousel/onboarding_carousel_page1.dart';
import 'package:mars_scanner/modules/onboarding/view/onBoarding_carousel/onboarding_carousel_page2.dart';
import 'package:mars_scanner/modules/onboarding/view/onBoarding_carousel/onboarding_carousel_page3.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:video_player/video_player.dart';

import '../../../../helpers/haptics.dart';
import '../../../../themes/app_text_theme.dart';
import '../../controller/signup_controller.dart';

import '../../../../common/animators/onboarding_scroll_text.dart';

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({
    super.key,
    this.isFromIntro,
    this.initialPage,
    this.videoControllers,
    this.isNotFirstTime,
  });

  final bool? isFromIntro;
  final int? initialPage;
  final List<VideoPlayerController>? videoControllers;
  final bool? isNotFirstTime;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel>
    with SingleTickerProviderStateMixin {
  final signupcontroller = Get.put(SignUpController());
  late KeyboardDetectionController keyboardDetectionController;

  late PageController _pageControllerMain;
  int _currentPageMain = 0;
  final int totalPages = 4;
  double _scrollOffset = 0.0;
  double globalScrollOffset = 0.0;
  late PageController _pageController;
  int _previousPageMain = 0; // Track the previous page index
  bool isSwiped = false;
  double proMetricsOffset = 0.0;
  final List<List<String>> headings = [
    ["THE NEW MUSIC", "BUSINESS"], // Page 1
    ["PRO", "METRICS"], // Page 2
    ["SHAREHOLDER", "MEETINGS"], // Page 3
    ["MARS", "MARKETS"], // Page 4
  ];
  bool isButtonPressed = false;
  bool isExiting = false;

  List<VideoPlayerController> videoControllers = [];
  List<String> videoAssets = [
    'assets/videos/Onboarding_S02-2.mp4',
    'assets/videos/Onboarding_S04.mp4'
  ];

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    initVideoControllers();
    _pageController = PageController();
    setPageController();
  }

  initVideoControllers() {
    if (widget.videoControllers != null) {
      videoControllers = widget.videoControllers!;
    } else {
      for (String asset in videoAssets) {
        final controller = VideoPlayerController.asset(
          asset,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
          ),
        )..initialize().then((_) {
            setState(() {});
          });
        videoControllers.add(controller);
      }
    }
  }

  setPageController() {
    _pageControllerMain = PageController(initialPage: widget.initialPage ?? 0);
    if (widget.initialPage != null) {
      _currentPageMain = widget.initialPage ?? 0;
      globalScrollOffset = 3.0;
      _scrollOffset = 1.0;
      isSwiped = true;
      proMetricsOffset = 1.0;
    }

    _pageControllerMain.addListener(() {
      if (_pageControllerMain.page != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in videoControllers) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override

  // package onboarding slider
  Widget build(BuildContext context) {
    final isBottomBarPresent = MediaQuery.of(context).viewInsets.bottom;
    debugPrint('142ssd: $isBottomBarPresent');
    FocusScope.of(context).unfocus();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        HapticFeedbacks.vibrate(FeedbackTypes.light);
        FocusScope.of(context).unfocus();

        if (_currentPageMain == 3) {
          setState(() {
            FocusScope.of(context).unfocus();
            isButtonPressed = false;
            Future.delayed(Duration(milliseconds: 35), () {
              isExiting = true;
            });
          });
          signupcontroller.updateIsChanged();
          // Navigator.of(context).pushReplacement(
          //   createCustomPageRoute(
          //     OnboardingIntro(
          //       isFromInviteCode: true,
          //     ),
          //     fade: true,
          //     duration: const Duration(milliseconds: 150),
          //   ),
          // );

          return; // Do not continue pop action
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        onHorizontalDragEnd: (details) async {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0 &&
              details.velocity.pixelsPerSecond.dx > 150 &&
              widget.isNotFirstTime == true) {
            HapticFeedbacks.vibrate(FeedbackTypes.light);
            final brightness = Theme.of(context).brightness;
            final textColor = brightness == Brightness.dark
                ? AppColors.white
                : AppColors.background;
            final shouldExit = await showCupertinoDialog<bool>(
              context: context,
              builder: (BuildContext context) => CupertinoTheme(
                data: CupertinoThemeData(
                  barBackgroundColor: textColor,
                  brightness: brightness,
                ),
                child: CupertinoAlertDialog(
                  title: Text(
                    'Exit App',
                    style: AppTextStyle.headerH3(color: textColor),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      'Are you sure you want to exit?',
                      style: AppTextStyle.bodyLarge(color: textColor),
                    ),
                  ),
                  actions: <CupertinoDialogAction>[
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'No',
                        style: AppTextStyle.headerH3(
                            color: AppColors.marsOrange600),
                      ),
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Yes',
                        style: AppTextStyle.headerH3(color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (shouldExit ?? false) {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            }
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            //  alignment: Alignment.topLeft,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification) {
                    // Calculate the scroll offset between the 3rd and 4th page
                    setState(() {
                      _scrollOffset = (_pageControllerMain.page ?? 0) - 2.0;
                      if (_scrollOffset < 0) _scrollOffset = 0;
                      if (_scrollOffset > 1) _scrollOffset = 1;

                      // Calculate scroll offset for all screens
                      globalScrollOffset = _pageControllerMain.page ?? 0.0;
                      if ((_pageControllerMain.page ?? 0) >= 0 &&
                          (_pageControllerMain.page ?? 0) <= 1) {
                        proMetricsOffset = _pageControllerMain.page ?? 0.0;
                      }
                    });
                  }
                  return true;
                },
                child: PageView(
                  controller: _pageControllerMain,
                  physics: _currentPageMain == 3
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(), // Normal scroll otherwise
                  onPageChanged: (int page) {
                    setState(() {
                      _previousPageMain = _currentPageMain;
                      _currentPageMain = page;
                      isSwiped = true;
                    });
                  },
                  children: [
                    OnboardingCarouselPage1(
                      isSwiped: isSwiped,
                      isFromIntro: widget.isFromIntro,
                      scrollOffset: globalScrollOffset,
                      currentPage: _currentPageMain,
                      previousPage:
                          widget.isFromIntro != null && _previousPageMain == 0
                              ? -1
                              : _previousPageMain,
                      videoController: videoControllers[0],
                    ),
                    OnboardingCarouselPage2(
                      pageController: _pageController,
                      scrollOffset: globalScrollOffset,
                      currentPage: _currentPageMain,
                      previousPage: _previousPageMain,
                    ),
                    OnboardingCarouselPage3(
                      scrollOffset: globalScrollOffset,
                      currentPage: _currentPageMain,
                      previousPage: _previousPageMain,
                      controller: videoControllers[1],
                    ),
                    InviteCode(
                        isfromOtherPage: widget.initialPage != null,
                        isExiting: isExiting,
                        isCarouselButtonsPressed: isButtonPressed,
                        isFromCarousel: true,
                        pageController: _pageControllerMain)
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(0, -315.h),
                child: HeadingTextAnimation(
                  initialHeadingNo: widget.initialPage,
                  pageController: _pageControllerMain,
                  slideEffects: true,
                  richHeadings: headings,
                  richTextColor: AppColors.white,
                ),
              ),
              // Animate bottom based on scroll offset
              Positioned(
                  bottom: 97.h + (_scrollOffset * 620),
                  left: 28.5.w - (_scrollOffset * 520),
                  right: 26.5.w + (_scrollOffset * 320),
                  child: OnboardingCarouselText(
                    pageController: _pageControllerMain,
                  )),

              // Animated Controller based on scroll position (move down as the user swipes)
              Positioned(
                bottom: 30.h + (_scrollOffset * 620),
                left: 8.w - (_scrollOffset * 520),
                right: 0.w + (_scrollOffset * 320),
                child: BackgroundController(
                  currentPage: _currentPageMain,
                  totalPage: totalPages,
                  controllerColor: Colors.grey,
                  indicatorAbove: false,
                  hasFloatingButton: true,
                  indicatorPosition: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The BackgroundController widget (bottom indicator)
class BackgroundController extends StatelessWidget {
  final int currentPage;
  final int totalPage;
  final Color? controllerColor;
  final bool indicatorAbove;
  final double indicatorPosition;
  final bool hasFloatingButton;

  const BackgroundController({
    super.key,
    required this.currentPage,
    required this.totalPage,
    required this.controllerColor,
    required this.indicatorAbove,
    required this.hasFloatingButton,
    required this.indicatorPosition,
  });

  @override
  Widget build(BuildContext context) {
    return (currentPage == totalPage - 1) && hasFloatingButton
        ? const SizedBox.shrink() // Hide indicator on the last page
        : Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(context),
            ),
          );
  }

  List<Widget> _buildPageIndicator(BuildContext context) {
    List<Widget> list = [];
    for (int i = 0; i < totalPage; i++) {
      list.add(i == currentPage
          ? _indicator(true, context)
          : _indicator(false, context));
    }
    return list;
  }

  Widget _indicator(bool isActive, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.only(
          right: 8.0, bottom: indicatorAbove ? indicatorPosition : 10),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xffC9C9C9) : const Color(0xff585858),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}
