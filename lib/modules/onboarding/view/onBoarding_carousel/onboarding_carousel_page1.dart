import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:lottie/lottie.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../utils/asset_constants.dart';

// import '../../../../helpers/lottie_decoder.dart';
// import '../../../../utils/asset_constants.dart';

class OnboardingCarouselPage1 extends StatelessWidget {
  const OnboardingCarouselPage1({
    super.key,
    this.isFromIntro,
    required this.currentPage,
    required this.scrollOffset,
    required this.previousPage,
    required this.isSwiped,
    required VideoPlayerController? videoController,
  }) : _videoController = videoController;

  final bool? isFromIntro;
  final int currentPage;
  final double scrollOffset;
  final int previousPage;
  final bool isSwiped;
  final VideoPlayerController? _videoController;

  @override
  Widget build(BuildContext context) {
    //  final screenheight = MediaQuery.of(context).size.height;
    return Container(
      color: AppColors.background,
      //  margin: EdgeInsets.only(top: 104.5.h),
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 104.5.h),
          SvgPicture.asset(
            AppAssets.marsMarketWord,
            color: Colors.transparent,
          ),
          SizedBox(height: 20.h),
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 345.w,
                height: 484.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ClipRect(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: _videoController != null
                                ? VisibilityDetector(
                                    onVisibilityChanged: (visibilityInfo) {
                                      if (_videoController
                                          .value.isInitialized) {
                                        if (visibilityInfo.visibleFraction >
                                            0.5) {
                                          // Play the video when more than 50% is visible
                                          _videoController.play();
                                          _videoController.setLooping(true);
                                        } else {
                                          // Pause the video when less than 50% is visible
                                          _videoController.pause();
                                          _videoController.setLooping(false);
                                        }
                                      }
                                    },
                                    key: Key('video-key-1%'),
                                    child: Transform.scale(
                                      scale: 1,
                                      child: SizedBox(
                                        width:
                                            _videoController.value.size.width,
                                        height:
                                            _videoController.value.size.height,
                                        child: VideoPlayer(_videoController),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ),
                        ),
                        // Positioned.fill(
                        //   child: FittedBox(
                        //     fit: BoxFit.cover,
                        //     child: Lottie.asset(
                        //       AppAssets.onBoardingV2,
                        //       decoder: customDecoder,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 128.h,
          ),
        ],
      ),
    );
  }
}
