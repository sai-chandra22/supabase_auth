import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/animation.dart';
import 'package:mars_scanner/modules/auth/controller/biometric_auth_controller.dart';
import 'package:mars_scanner/modules/auth/view/biometric_auth_screen.dart';
import 'package:lottie/lottie.dart';
import '../../../cache/local/shared_prefs.dart';
import '../../../helpers/lottie_decoder.dart';
import '../../home_screen/view/app_screens_main_tab.dart';
import '../../onboarding/view/onBoarding_carousel/onboarding_carousel.dart';
import '../../../utils/asset_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  bool isUserLoggedIn = false;
  final BiometricAuthController _authController =
      Get.put(BiometricAuthController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
    _lottieController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _initializeData();

    // Add a listener to navigate when the animation completes
    _lottieController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _navigateBasedOnUserState();
      }
    });
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _checkIfUserIsLoggedIn(),
        _authController.checkBiometricSupport(),
      ]);
    } catch (e) {
      debugPrint('Error initializing data: $e');
    }
  }

  void prints(var s1) {
    String s = s1.toString();
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
  }

  Future<void> _checkIfUserIsLoggedIn() async {
    final user = await LocalStorage.getUserModel(); // Retrieve user data

    setState(() {
      isUserLoggedIn = user != null; // Check if user data exists
    });

    if (isUserLoggedIn) {}
  }

  // Navigate based on whether the user is logged in or not
  void _navigateBasedOnUserState() async {
    final user = await LocalStorage.getUserModel();

    if (isUserLoggedIn) {
      // Check if biometrics is available and proceed accordingly
      if (!_authController.hasDevicePassword.value &&
          !_authController.isBiometricsAvailable.value) {
        // If no security is available, go directly to home screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(createCustomPageRoute(
          const HomeScreenTabControl(
            isFromSplashScreen: true,
          ),
          topToBottom: true,
        ));
      } else {
        // If security is available, go to biometric screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(createCustomPageRoute(
          BiometricAuthScreen(
            userName: "${user?.firstName ?? ''} ${user?.lastName ?? ''}",
          ),
          topToBottom: true,
        ));
      }
    } else {
      if (await isNotFirstTime()) {
        Navigator.of(context).pushReplacement(createCustomPageRoute(
          OnboardingCarousel(
            isFromIntro: true,
            initialPage: 3,
            isNotFirstTime: true,
          ),
          topToBottom: true,
          duration: const Duration(milliseconds: 600),
        ));
      } else {
        Navigator.of(context).pushReplacement(createCustomPageRoute(
          OnboardingCarousel(
            isFromIntro: true,
            initialPage: 3,
            isNotFirstTime: true,
          ),
          topToBottom: true,
          duration: const Duration(milliseconds: 600),
        ));
      }
    }
  }

  Future<bool> isNotFirstTime() async {
    final flag = await LocalStorage.isUserFirstTime();
    return flag;
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusScope.of(context).unfocus();
    return Scaffold(
      backgroundColor: const Color(0xff222222),
      body: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.408),
          ),
          Center(
            child: SizedBox(
              width: 393.w,
              height: 852.h,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Lottie.asset(
                  AppAssets.onBoardingV0,
                  controller: _lottieController,
                  onLoaded: (composition) {
                    _lottieController.forward();
                    _lottieController.duration = composition.duration;
                  },
                  decoder: customDecoder,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
