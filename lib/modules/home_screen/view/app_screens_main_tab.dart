import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/helpers/custom_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../cache/local/shared_prefs.dart';
import '../../../common/animation.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../../themes/app_text_theme.dart';
import '../../../utils/colors.dart';
import '../../onboarding/view/onBoarding_carousel/onboarding_carousel.dart';

class HomeScreenTabControl extends StatefulWidget {
  final bool isFromSplashScreen;

  const HomeScreenTabControl({
    super.key,
    this.isFromSplashScreen = false,
  });

  @override
  State<HomeScreenTabControl> createState() => _HomeScreenTabControlState();
}

class _HomeScreenTabControlState extends State<HomeScreenTabControl>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  final screenNames = [
    'Home Screen',
  ];
  late StreamSubscription _sub;
  bool isNotificationOpen = false;

  @override
  void initState() {
    super.initState();
    debugPrint("initState of HomeScreenTabControl 70ssd");
    _pageController = PageController(initialPage: _currentIndex);
    if (widget.isFromSplashScreen == true) {
      handleSessionExpired();
    }
  }

  Future<void> handleSessionExpired() async {
    debugPrint(
        '78ssd handleSessionExpired ${sb.Supabase.instance.client.auth.currentSession}');
    if (sb.Supabase.instance.client.auth.currentSession == null) {
      await LocalStorage.clearLocalData();
      showCustomSnackbar('Session Expired',
          'Your session has timed out. Please log in again.');
      Get.offAll(
        () => OnboardingCarousel(
          isFromIntro: true,
          initialPage: 3,
          isNotFirstTime: true,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Screens for each tab

  navigateBack() async {
    if (_currentIndex > 0) {
      final index = _currentIndex - 1;
      _currentIndex = index;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        FocusScope.of(context).unfocus();
      });
    } else {
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
                  style: AppTextStyle.headerH3(color: AppColors.marsOrange600),
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
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        navigateBack();
        return;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        body: GestureDetector(
            child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await LocalStorage.clearLocalData();
                  TokenExpiryManager().logout();
                  Navigator.of(context)
                      .pushReplacement(createCustomSpringPageRoute(
                    OnboardingCarousel(
                      isFromIntro: true,
                      initialPage: 3,
                      isNotFirstTime: true,
                    ),
                    //  OnboardingIntro(isFromInviteCode: true),
                    slideToRight: true,
                  ));
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
