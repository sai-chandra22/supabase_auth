import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// import '../../../../helpers/lottie_decoder.dart';
// import '../../../../utils/asset_constants.dart';
import '../../../../utils/asset_constants.dart';
import '../../../../utils/colors.dart';

class OnboardingCarouselPage3 extends StatelessWidget {
  const OnboardingCarouselPage3({
    super.key,
    required this.currentPage,
    required this.scrollOffset,
    required this.previousPage,
    required this.controller,
  });

  final int currentPage;
  final double scrollOffset;
  final int previousPage;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    //  final screenheight = MediaQuery.of(context).size.height;
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 104.5.h,
          ),
          SvgPicture.asset(
            AppAssets.marsMarketWord,
            color: Colors.transparent,
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: 345.w,
            height: 484.h,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: controller.value.isInitialized
                      ? VisibilityDetector(
                          onVisibilityChanged: (visibilityInfo) {
                            if (controller.value.isInitialized) {
                              if (visibilityInfo.visibleFraction > 0.5) {
                                // Play the video when more than 50% is visible
                                controller.play();
                                controller.setLooping(true);
                              } else {
                                // Pause the video when less than 50% is visible
                                controller.pause();
                                controller.setLooping(false);
                              }
                            }
                          },
                          key: Key('video-key-3%'),
                          child: Transform.scale(
                            scale: 1,
                            child: SizedBox(
                              width: controller.value.size.width,
                              height: controller.value.size.height,
                              child: VideoPlayer(controller),
                            ),
                          ))
                      : Container(),
                ),
              ),
            ),
          ),
          // SizedBox(
          //   width: 345.w,
          //   height: 484.h,
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(8),
          //     child: ClipRect(
          //       child: FittedBox(
          //         fit: BoxFit.cover,
          //         child: Lottie.asset(
          //           AppAssets.onBoardingV4,
          //           decoder: customDecoder,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(
            height: 128.h,
          ),
        ],
      ),
    );
  }
}
