import 'dart:core';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mars_scanner/utils/colors.dart';

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
    return Scaffold(backgroundColor: AppColors.background, body: Container());
  }
}

void prints(var s1) {
  String s = s1.toString();
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
}
