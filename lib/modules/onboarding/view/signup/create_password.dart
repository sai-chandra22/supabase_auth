import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/modules/onboarding/view/signup/verify_mail.dart';
import 'package:mars_scanner/utils/app_texts.dart';
import 'package:mars_scanner/utils/colors.dart';
import '../../../../common/animation.dart';
import '../../../../common/buttons/custom_button.dart';
import '../../../../common/textfields/border_less_field.dart';
import '../../../../helpers/haptics.dart';
import '../../../../themes/app_text_theme.dart';
import 'package:mars_scanner/utils/asset_constants.dart';

import '../../controller/signup_controller.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({
    super.key,
    this.isForCarousel,
    this.focusNode,
    this.pageController,
    this.isForNormalSignUp,
  });

  final bool? isForCarousel;
  final FocusNode? focusNode;
  final PageController? pageController;
  final bool? isForNormalSignUp;

  @override
  CreatePasswordState createState() => CreatePasswordState();
}

class CreatePasswordState extends State<CreatePassword>
    with SingleTickerProviderStateMixin {
  final SignUpController signUpController = Get.find<SignUpController>();
  late FocusNode _focusNode;

  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordLengthValid = false;
  bool hasUpperLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;
  bool isPasswordValid = false;

  void navigateToScreen() {
    // Navigator.of(context).push(
    //   CustomPageRoute(
    //     child:
    //         const EnterPhoneNumber(), // Navigate to CreatePassword with custom animation
    //   ),
    // );
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      isPasswordLengthValid = password.length >= 8 && password.length <= 32;
      hasUpperLowerCase = password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]'));
      hasNumber = password.contains(RegExp(r'[0-9]'));
      hasSpecialCharacter =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      isPasswordValid = isPasswordLengthValid &&
          hasUpperLowerCase &&
          hasNumber &&
          hasSpecialCharacter;
    });
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    if (widget.pageController != null) {
      // Initial focus request with slight delay to ensure widget is mounted
      Future.delayed(Duration(milliseconds: 50), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
      widget.pageController!.addListener(() {
        if ((widget.pageController!.page == 3.0) ||
            (widget.pageController!.page == 4.0 &&
                widget.isForNormalSignUp == true)) {
          Future.delayed(Duration(milliseconds: 50), () {
            if (mounted) {
              _focusNode.requestFocus();
            }
          });
        }
      });
    }
    _passwordController.addListener(_validatePassword);
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    //  HapticFeedbacks.vibrate(FeedbackTypes.light);
    Navigator.of(context).push(
      CustomPageRoute(
        child: const VerifyEmail(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isForCarousel != null
        ? forCarouselScreen()
        : createPasswordScreen();
  }

  Widget forCarouselScreen() {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.only(bottom: 2.h, left: 32.w),
            alignment: Alignment.centerLeft,
            height: 32.h,
            child: BorderLessTextField(
              onChanged: (p0) {
                signUpController.validatePassword();
                // _validatePassword();
              },
              focusNode: _focusNode,
              controller: signUpController.passwordController,
              //  _passwordController,
              isForPassword: true,
            ),
          ),
          SizedBox(height: 25.h),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: _buildPasswordValidationCriteria(),
          ),
        ],
      ),
    );
  }

  Scaffold createPasswordScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 66.h),
              padding: EdgeInsets.only(left: 24.w),
              width: 393.w,
              height: 24.h,
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: GestureDetector(
                  onTap: _navigateBack,
                  child: SvgPicture.asset(
                    AppAssets.chevronLeft,
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.only(left: 10.w),
              // color: Colors.green,
              width: 393.w,
              height: 331.h,
              child: Container(
                // color: Colors.blue,
                width: 345.w,
                height: 239.h,
                margin: EdgeInsets.only(top: 24.h, left: 24.w, right: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.createPassword,
                      style: AppTextStyle.headerH3(
                          color: AppColors.white,
                          letterSpacing: -1,
                          lineHeight: 1),
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      height: 28.h,
                      child: BorderLessTextField(
                        onChanged: (p0) {
                          _validatePassword();
                        },
                        controller: _passwordController,
                        isForPassword: true,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    _buildPasswordValidationCriteria(),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            CustomTextButton(
              isActive: isPasswordValid,
              text: AppTexts.continueText.toUpperCase(),
              backgroundColor: AppColors.marsOrange600,
              textColor: AppColors.white,
              onPressed: () {
                HapticFeedbacks.vibrate(FeedbackTypes.light);
                navigateToScreen();
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordValidationCriteria() {
    return SizedBox(
      height: 150.h,
      child: Obx(() {
        final SignUpController signUpController = Get.find<SignUpController>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCriteriaRow(
                AppTexts.charText,
                widget.isForCarousel != null
                    ? signUpController.isPasswordLengthValid.value
                    : isPasswordLengthValid),
            _buildCriteriaRow(
                AppTexts.caseSensitvityText,
                widget.isForCarousel != null
                    ? signUpController.hasUpperLowerCase.value
                    : hasUpperLowerCase),
            _buildCriteriaRow(
                AppTexts.number,
                widget.isForCarousel != null
                    ? signUpController.hasNumber.value
                    : hasNumber),
            _buildCriteriaRow(
                AppTexts.specialChar,
                widget.isForCarousel != null
                    ? signUpController.hasSpecialCharacter.value
                    : hasSpecialCharacter),
          ],
        );
      }),
    );
  }

  Widget _buildCriteriaRow(String text, bool isValid) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(right: 0.w, top: 0.h, bottom: 1.h),
          // height: 16.h,
          // width: 16.w,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isValid ? AppColors.marsOrange600 : AppColors.hintColor),
          child: Center(
            child: isValid
                ? Icon(
                    Icons.check,
                    size: 16.sp,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.circle,
                    size: 16.sp,
                    color: AppColors.background,
                  ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: AppTextStyle.bodyRegularBold(
            color: isValid ? AppColors.white : const Color(0xffC9C9C9),
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
