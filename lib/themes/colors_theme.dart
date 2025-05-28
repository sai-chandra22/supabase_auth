import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class ThemeColor {
  ThemeData get themeData {
    ColorScheme marsAppColorScheme = ColorScheme(
      // primary green
      primary: AppColors.background,
      // primary blue
      primaryContainer: Color(0xff239DD1),
      // gradient 1
      surface: Color(0xff2E2739),
      // gradient 2
      background: Color(0xff141414),
      // secondary grey
      //secondary: Color(0xffF1F3F4),
      secondary: Color(0xff2E2739),
      // secondary dark grey
      secondaryContainer: Color(0xff606260),
      // secondary red
      error: Color(0xffE2173A),
      // primary green
      onPrimary: Color(0xFFFFFFFF),
      // primary blue
      onSecondary: Color(0xff239DD1),
      // secondary grey
      onSurface: Color(0xff2E2739),
      // secondary dark grey
      onBackground: Color(0xffffffff),
      // secondary red
      onError: Color(0xffE2173A),
      // white
      brightness: Brightness.light,
    );

    return ThemeData(
        useMaterial3: true,
        colorScheme: marsAppColorScheme,
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS:
              CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
        }));
  }
}
