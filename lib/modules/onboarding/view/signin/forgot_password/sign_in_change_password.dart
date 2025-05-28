import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mars_scanner/common/animation.dart';
import 'package:mars_scanner/modules/onboarding/view/signin/sign_in_step_1.dart';
import 'package:mars_scanner/modules/onboarding/view/signup/verify_mail.dart';
import 'package:mars_scanner/utils/app_texts.dart';
import 'package:mars_scanner/utils/asset_constants.dart';
import 'package:mars_scanner/utils/colors.dart';

import '../../../../../common/buttons/custom_button.dart';
import '../../../../../common/textfields/custom_textfield_widget.dart';
import '../../../../../helpers/haptics.dart';
import '../../../../../themes/app_text_theme.dart';
import '../../../controller/signin_controller.dart';

class ChangePassword extends StatefulWidget {
  final bool doAnimation;
  final String userEmail;

  const ChangePassword({
    super.key,
    this.doAnimation = false,
    required this.userEmail,
  });

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword>
    with SingleTickerProviderStateMixin {
  FocusNode focusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final signInController = Get.find<SignInController>();
  bool isPasswordLengthValid = false;
  bool hasUpperLowerCase = false;
  bool hasNumber = false;
  bool hasSpecialCharacter = false;
  bool isPasswordValid = false;

  void navigateBackToScreen() {
    Navigator.of(context).push(createCustomPageRoute(
        VerifyEmail(
          isForPasswordChange: true,
          userEmail: widget.userEmail,
        ),
        fade: true,
        duration: Duration(milliseconds: 250)));
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
    //  _passwordController.text = widget.userEmail;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
    super.initState();

    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateBack() {
    // HapticFeedbacks.vibrate(FeedbackTypes.light);
    navigateBackToScreen();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 0 &&
              details.velocity.pixelsPerSecond.dx > 150) {
            _navigateBack();
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: 38.h),
                  Padding(
                    padding: EdgeInsets.only(left: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.setNewPassword,
                          style: AppTextStyle.headerH3(
                              color: AppColors.white,
                              letterSpacing: -1,
                              lineHeight: 1.2),
                        ),
                        SizedBox(height: 35.h),
                        SizedBox(
                            width: 323.w,
                            child: CustomTextField(
                              focusNode: focusNode,
                              onChanged: (value) {
                                _validatePassword();
                              },
                              textController: _passwordController,
                              hintText: AppTexts.yourPassword,
                              isForPassword: true,
                            )),
                        SizedBox(height: 35.h),
                        _buildPasswordValidationCriteria()
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h, left: 24.w),
                    child: CustomTextButton(
                        isActive: isPasswordValid,
                        text: AppTexts.continueText.toUpperCase(),
                        backgroundColor: AppColors.marsOrange600,
                        textColor: AppColors.white,
                        onPressed: () async {
                          HapticFeedbacks.vibrate(FeedbackTypes.light);
                          final flag =
                              await signInController.updateUserPassword(
                                  _passwordController.text, widget.userEmail);
                          if (flag) {
                            Navigator.of(context).push(createCustomPageRoute(
                                SignInStep1(
                                  fromInviteCode: true,
                                ),
                                fade: true,
                                duration: Duration(milliseconds: 250)));
                          }
                        }),
                  ),
                ],
              ),
              Obx(() {
                return signInController.isLoading.value
                    ? Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                              child: CupertinoActivityIndicator(
                            radius: 10.r,
                            color: AppColors.white,
                          )
                              //  CircularProgressIndicator(
                              //   color: AppColors.marsOrange600,
                              // ),
                              ),
                        ),
                      )
                    : const SizedBox.shrink(); // Hide if not loading
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordValidationCriteria() {
    return SizedBox(
        height: 140.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCriteriaRow(AppTexts.charText, isPasswordLengthValid),
            _buildCriteriaRow(AppTexts.caseSensitvityText, hasUpperLowerCase),
            _buildCriteriaRow(AppTexts.number, hasNumber),
            _buildCriteriaRow(AppTexts.specialChar, hasSpecialCharacter),
          ],
        ));
  }

  Widget _buildCriteriaRow(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: isValid ? AppColors.marsOrange500 : AppColors.hintColor,
          size: 20.w,
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
