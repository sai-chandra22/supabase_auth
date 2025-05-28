import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mars_scanner/utils/app_texts.dart';
import '../../utils/colors.dart';

class OnboardingCarouselText extends StatefulWidget {
  final PageController pageController;

  const OnboardingCarouselText({super.key, required this.pageController});

  @override
  OnboardingCarouselTextState createState() => OnboardingCarouselTextState();
}

class OnboardingCarouselTextState extends State<OnboardingCarouselText> {
  double scrollOffset = 0.0;

  final List<String> texts = [
    AppTexts.investInYourFavoriteArtists, // Page 1
    AppTexts.trackArtists, // Page 2
    AppTexts.gainAccess, // Page 3 and 4 (Same text for page 3 and 4)
    AppTexts.gainAccess,
  ];

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(() {
      setState(() {
        scrollOffset = widget.pageController.page ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the current page and next page based on scroll offset
    int currentPage = scrollOffset.floor(); // Active page
    int nextPage =
        (scrollOffset > currentPage) ? currentPage + 1 : currentPage - 1;

    // Ensure valid page index
    nextPage = nextPage.clamp(0, texts.length - 1);

    // Calculate opacity for current and next text
    double currentOpacity = 1 - (scrollOffset - currentPage).abs();
    double nextOpacity = (scrollOffset - currentPage).abs();

    // Calculate text height for resizing (1 line vs 2 lines text)
    double currentHeight =
        _getTextHeight(texts[currentPage], context, currentPage);
    double nextHeight = _getTextHeight(texts[nextPage], context, nextPage);
    double interpolatedHeight = currentHeight +
        ((nextHeight) - currentHeight) * (scrollOffset - currentPage).abs();
    double extraHeight = 0;
    if (scrollOffset > 1) {
      extraHeight = -4.h +
          ((scrollOffset - 1) *
              (18.h)); // 18.h is the difference between -4.h and 14.h // Gradually increases from 0 to 14.h
    } else {
      extraHeight = -4.h;
    }

    return Container(
      alignment: Alignment.center,
      child: Center(
        child: AnimatedContainer(
          decoration: BoxDecoration(
            // color: Colors.amber, // Ensure container has no background
            border: Border.all(color: Colors.transparent),
          ),
          duration: const Duration(milliseconds: 20),
          curve: Curves.easeInOut,
          height: interpolatedHeight + extraHeight,
          // width: 320.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Current page text (fade out smoothly)
              Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: _buildText(texts[currentPage], context),
              ),
              // Next page text (fade in smoothly)
              Opacity(
                opacity: nextOpacity.clamp(0.0, 1.0),
                child: _buildText(texts[nextPage], context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the text widget
  Widget _buildText(String text, BuildContext context) {
    return text.length > 31
        ? Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                letterSpacing: 0,
                color: AppColors.marsOrange50,
                fontFamily: 'SpaceGrotesk',
                fontWeight: FontWeight.w500, // Medium
                fontSize: 14.sp,
                height: 1),
          )
        : FittedBox(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  letterSpacing: 0,
                  color: AppColors.marsOrange50,
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w500, // Medium
                  fontSize: 14.sp,
                  height: 1),
            ),
          );
  }

  // Method to calculate the height of the text dynamically
  double _getTextHeight(String text, BuildContext context, [int? index]) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          letterSpacing: 0,
          color: AppColors.marsOrange50,
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w500, // Medium
          fontSize: 14.sp,
        ),
      ),
      maxLines: 6,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 320.w);
    return textPainter.size.height.h +
        (index == 0
            ? 5.h
            : index == 2
                ? -12.h
                : index == 1
                    ? 5.h
                    : 0.h);
  }
}
