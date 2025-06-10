import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../themes/app_text_theme.dart';
import '../../../utils/colors.dart';
import '../../utils/asset_constants.dart';

class HeadingTextAnimation extends StatefulWidget {
  final PageController pageController;
  final List<List<String>>?
      richHeadings; // Accept list of lists for rich text headings
  final List<String>?
      plainHeadings; // Accept list of strings for plain text headings
  final bool slideEffects; // Boolean to toggle slide effects
  final bool? isMultipleText;
  final int? initialHeadingNo;
  final bool? isForSignUp;
  final Color? richTextColor;
  final bool isPurchaseFlow;

  const HeadingTextAnimation({
    super.key,
    required this.pageController,
    this.richHeadings,
    this.plainHeadings,
    this.slideEffects = false,
    this.isMultipleText,
    this.initialHeadingNo,
    this.isForSignUp,
    this.richTextColor, // Default to true for slide effects
    this.isPurchaseFlow = false, // Default to true for slide effects
  }) : assert(
            (richHeadings != null && plainHeadings == null) ||
                (richHeadings == null && plainHeadings != null),
            'Provide either richHeadings or plainHeadings, not both.');

  @override
  HeadingTextAnimationState createState() => HeadingTextAnimationState();
}

class HeadingTextAnimationState extends State<HeadingTextAnimation> {
  double scrollOffset = 0.0;
  bool isChanged = false;

  @override
  void initState() {
    if (widget.isPurchaseFlow != true) {}
    super.initState();
    if (widget.initialHeadingNo != null) {
      scrollOffset = widget.initialHeadingNo!.toDouble();
    }
    widget.pageController.addListener(() {
      if (mounted) {
        setState(() {
          scrollOffset = widget.pageController.page ?? 0;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.pageController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Decide whether to use rich text or plain text
    bool isRichText =
        widget.richHeadings != null && widget.isMultipleText == null;

    // Get the current headings list
    var headings = isRichText
        ? widget.richHeadings
        : widget.isMultipleText == true
            ? widget.richHeadings
            : widget.plainHeadings;

    // Calculate the current and next pages based on scrollOffset
    int currentPage = scrollOffset.floor(); // Active page

    int nextPage =
        (scrollOffset > currentPage) ? currentPage + 1 : currentPage - 1;

    // Ensure valid next page index
    nextPage = nextPage.clamp(0, headings!.length - 1);

    // Calculate opacity for current and next headings
    double currentOpacity = 1 - (scrollOffset - currentPage).abs();
    double nextOpacity = (scrollOffset - currentPage).abs();

    // Calculate sliding direction based on character length (for rich text)
    double slideOffset = widget.slideEffects
        ? _calculateSlideOffset(
            currentPage, nextPage, scrollOffset - currentPage, isRichText)
        : 0;

    // Calculate padding based on the slideEffects boolean
    EdgeInsets nextPagePadding = widget.slideEffects
        ? _calculatePaddingForNextPage(currentPage, nextPage, scrollOffset)
        : EdgeInsets.zero; // No padding when slideEffects is false

    return Container(
      alignment: widget.slideEffects ? Alignment.center : Alignment.centerLeft,
      width: double.infinity,
      child: Stack(
        alignment:
            widget.slideEffects ? Alignment.center : Alignment.centerLeft,
        children: [
          // Current heading text (Fade out and slide if effects enabled)
          Opacity(
            opacity: currentOpacity.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(slideOffset, 0),
              child: isRichText
                  ? _buildRichText(widget.richHeadings![currentPage])
                  : widget.isMultipleText != null
                      ? _buildMultipleText(widget.richHeadings![currentPage])
                      : _buildPlainText(widget.plainHeadings![currentPage]),
            ),
          ),
          // Next heading text (Fade in and slide if effects enabled)
          Opacity(
            opacity: nextOpacity.clamp(0.0, 1.0),
            child: Padding(
              padding:
                  nextPagePadding, // Apply padding only if slideEffects is true
              child: isRichText
                  ? _buildRichText(widget.richHeadings![nextPage])
                  : widget.isMultipleText != null
                      ? _buildMultipleText(widget.richHeadings![nextPage])
                      : _buildPlainText(widget.plainHeadings![nextPage]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleText(List<String> heading) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlainText(heading[0]),
          SizedBox(height: 5.7.h),
          if (widget.isPurchaseFlow != true) ...[
            Obx(() {
              return Text(
                heading[1],
                style: AppTextStyle.bodyRegular(
                    color: AppColors.grey, letterSpacing: 0),
              );
            }),
          ]
        ]);
  }

  // Method to build RichText widget
  Widget _buildRichText(List<String> heading) {
    return heading[0] == "MARS" && heading[1] == "MARKETS"
        ? Padding(
            padding: EdgeInsets.only(top: 0.w),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                      //   alignment: PlaceholderAlignment.center,
                      child: SvgPicture.asset(
                    AppAssets.marsMarketWord,
                    //  color: AppColors.white,
                  )),
                ],
              ),
            ),
          )
        : RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "${heading[0]} ", // First part of heading
              style: AppTextStyle.headerH2Brand(
                color: widget.richTextColor ?? AppColors.marsOrange600,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: heading[1], // Second part of heading
                  style: AppTextStyle.headerH2Brand(color: Colors.white),
                ),
              ],
            ),
          );
  }

  // Method to build plain text widget
  Widget _buildPlainText(String heading) {
    return Text(
      heading,
      textAlign: TextAlign.left,
      style: AppTextStyle.headerH3(
        color: AppColors.white,
        letterSpacing: -0.1,
      ),
    );
  }

  // Method to calculate the slide offset based on character length difference
  double _calculateSlideOffset(int currentPage, int nextPage,
      double transitionProgress, bool isRichText) {
    int currentLength, nextLength;

    if (isRichText) {
      currentLength = widget.richHeadings![currentPage][0].length +
          widget.richHeadings![currentPage][1].length;
      nextLength = widget.richHeadings![nextPage][0].length +
          widget.richHeadings![nextPage][1].length;
    } else {
      currentLength = widget.plainHeadings![currentPage].length;
      nextLength = widget.plainHeadings![nextPage].length;
    }

    // Determine the direction of slide based on character count
    if (nextLength > currentLength) {
      // Slide left if next text is longer
      return -50 * transitionProgress;
    } else if (nextLength < currentLength) {
      // Slide right if next text is shorter
      return 50 * transitionProgress;
    } else {
      // No slide if both texts have the same length
      return 0;
    }
  }

  // Calculate padding for the next page based on scrollOffset and slide effects
  EdgeInsets _calculatePaddingForNextPage(
      int currentPage, int nextPage, double scrollOffset) {
    return currentPage == 2 && scrollOffset > 2
        ? EdgeInsets.only(
            right: _calculatePadding(scrollOffset - currentPage, true))
        : EdgeInsets.only(
            left: currentPage == 1 && scrollOffset > 1
                ? _calculatePadding(scrollOffset - currentPage)
                : 0);
  }

  // Method to calculate padding transition
  double _calculatePadding(double offset, [bool? isRight]) {
    double startPadding = isRight == true ? 170.h : 60.h; // Start with padding
    double finalPadding = 0.h; // End with padding of 0.h

    // Cap the transition at offset 0.85
    if (offset >= 0.85) {
      return finalPadding; // Once offset reaches 0.85 or more, the padding should be 0
    }

    // Interpolate the padding between start and final values
    double calculatedPadding =
        startPadding - ((startPadding - finalPadding) * (offset / 0.85));

    return calculatedPadding.h;
  }
}
