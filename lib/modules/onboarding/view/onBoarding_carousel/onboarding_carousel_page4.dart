import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mars_scanner/common/buttons/custom_button.dart';
import 'package:mars_scanner/modules/onboarding/controller/signup_controller.dart';
import 'package:mars_scanner/utils/colors.dart';
import '../../../../common/animation.dart';
import '../../../../helpers/haptics.dart';
import '../../../../utils/app_texts.dart';
import '../../../../utils/asset_constants.dart';
import '../signin/social_sign_in.dart';

class InviteCode extends StatefulWidget {
  final bool? fromStep2;
  final bool isFromCarousel;
  final PageController? pageController; // Add this to track the scroll offset
  final bool isCarouselButtonsPressed;
  final bool? isExiting;
  final bool? isfromOtherPage;

  const InviteCode({
    super.key,
    this.fromStep2,
    this.isFromCarousel = false,
    this.pageController, // Pass the PageController here
    this.isCarouselButtonsPressed = false,
    this.isExiting,
    this.isfromOtherPage,
  });

  @override
  State<InviteCode> createState() => _InviteCodeState();
}

class _InviteCodeState extends State<InviteCode> with TickerProviderStateMixin {
  final signUpController = Get.find<SignUpController>();

  late AnimationController _directNavController;
  late Animation<double> _animation;
  bool isButtonPressed = false;

  double scrollOffset = 0.0; // Keep track of the scroll offset

  @override
  void initState() {
    super.initState();
    _directNavController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Tween to animate from the bottom to its final position
    _animation = Tween<double>(
            begin: widget.isFromCarousel ? 0 : 750.0,
            end: isButtonPressed ? 700 : 0.0)
        .animate(
      CurvedAnimation(
        parent: _directNavController,
        reverseCurve: Curves.easeInOutCubicEmphasized,
        curve: Cubic(0.175, 0.885, 0.32, 1.14),
      ),
    );

    if (widget.isFromCarousel) {
      widget.pageController?.addListener(() {
        if (mounted) {
          setState(() {
            scrollOffset = widget.pageController?.page ?? 0;
          });
        }
      });
    } else {
      // Direct navigation: Create a linear animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _directNavController.forward(); // Start the animation
      });
    }
  }

  @override
  void dispose() {
    widget.pageController
        ?.removeListener(() {}); // Remove the listener when disposing
    _directNavController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The animation for the entire column based on the scroll offset
        _buildAnimatedColumn(),
        // Loading Overlay
        Obx(() {
          return signUpController.isLoading.value
              ? Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: 10.r,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(); // Hide if not loading
        }),
      ],
    );
  }

  // This is the animated column for swipe-based navigation
  Widget _buildAnimatedColumn() {
    double relativeScrollOffset = (scrollOffset == 0 ? 3 : scrollOffset) - 2;
    final screenheight = MediaQuery.of(context).size.height;
    debugPrint('screenheight: $screenheight');

    // Clamp the offset to keep it between 0 and 1
    double clampedScrollOffset = relativeScrollOffset.clamp(0.0, 1.0);
    double translateX =
        (1 - clampedScrollOffset) * 120; // Move horizontally from right to 0
    double translateY =
        (1 - clampedScrollOffset) * 600; // Move vertically from bottom to 0

    // Apply the translation to the column
    return Container(
      // margin: EdgeInsets.only(top: 104.5.h),
      color: AppColors.background,
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
          Transform.translate(
            offset: Offset(translateX, translateY),
            child: InviteCodeLottie(
              height: 484.h,
            ),
          ),
          SizedBox(height: 51.h),
          Transform.translate(
              offset: Offset(0, ((1 - clampedScrollOffset) * 150)),
              child: signInButton(true)),
          SizedBox(height: 17.h),
          Transform.translate(
            offset: Offset(translateX, translateY),
            child: signUpButton(true),
          ),
          SizedBox(height: 17.h),
        ],
      ),
    );
  }

  signUpButton([bool isFirstTime = false]) {
    return Opacity(
      opacity: 0,
      child: IgnorePointer(
        ignoring: true,
        child: CustomTextButton(
          changeFont: true,
          backgroundColor: AppColors.cardBackgroundFill,
          height: 48.h,
          width: 344.w,
          text: AppTexts.signUp.toUpperCase(),
          textColor: AppColors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  signInButton([bool isFirstTime = false]) {
    return CustomTextButton(
      changeFont: true,
      height: 48.h,
      width: 344.w,
      text: 'login'.toUpperCase(),
      textColor: AppColors.white,
      onPressed: () {
        setState(() {
          HapticFeedbacks.vibrate(FeedbackTypes.light);
          signUpController.toggleKeyBoardActivity(false);
          isButtonPressed = true;
          _directNavController.reverse();
        });
        Future.delayed(Duration(milliseconds: isFirstTime ? 0 : 200), () {
          if (!context.mounted) return;
          Navigator.push(
              context,
              createCustomPageRoute(SocialSignIn(),
                  fade: true, duration: Duration(milliseconds: 100)));
        });
      },
    );
  }
}

class InviteCodeLottie extends StatelessWidget {
  const InviteCodeLottie({
    super.key,
    this.height,
  });

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 345.w,
      height: height ?? 398.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Lottie.asset(
              AppAssets.onBoardingV5,
              // frameRate: FrameRate.max,
            ),
          ),
        ),
      ),
    );
  }
}
