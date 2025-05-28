import 'dart:core';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mars_scanner/utils/colors.dart';

import '../../../cache/local/shared_prefs.dart';
import '../../../common/animation.dart';
import '../../../helpers/caution.popup.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../onboarding/view/onBoarding_carousel/onboarding_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final mostRqstScrollController = ScrollController();
//  final expScrnArtistsScrollController = ScrollController();
  CarouselSliderController carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
          padding: EdgeInsets.only(top: 57.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      showLogoutSheet(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}

void prints(var s1) {
  String s = s1.toString();
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
}

Future<void> showLogoutSheet(BuildContext context) async {
  showModalBottomSheet(
    sheetAnimationStyle: AnimationStyle(
      duration: const Duration(milliseconds: 200), // Duration of animation
      curve: Curves.bounceInOut, // Customize the animation curve
      reverseCurve: Curves.easeOut, // Customize reverse animation curve
    ),
    useSafeArea: true,
    isDismissible: true,
    backgroundColor: AppColors.white,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r), // Add a radius of 36 to top left and right
      ),
    ),
    builder: (context) => ShmCautionPopUp(
      isForLogOut: true,
      onTap: () async {
        final authToken = await LocalStorage.getGraphQLApiToken();
        prints("authToken: $authToken");
        await LocalStorage.clearLocalData();
        TokenExpiryManager().logout();
        Navigator.of(context).pushReplacement(createCustomSpringPageRoute(
          OnboardingCarousel(
            isFromIntro: true,
            initialPage: 3,
            isNotFirstTime: true,
          ),
          //  OnboardingIntro(isFromInviteCode: true),
          slideToRight: true,
        ));
      },
    ),
  );
}
