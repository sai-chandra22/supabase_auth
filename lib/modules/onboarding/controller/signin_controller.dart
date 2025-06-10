import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../cache/local/shared_prefs.dart';
import '../../../helpers/custom_snackbar.dart';
import '../../../helpers/haptics.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../../services/graphQL/queries/onboarding_queries.dart';
import '../model/user_model.dart';

class SignInController extends GetxController {
  // Form Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController =
      TextEditingController(); // OTP controller

  // Track validation states
  var isEmailValid = false.obs;
  var isPasswordValid = false.obs;
  var isChangePassOtpInvalid = false.obs;

  final supabase = TokenExpiryManager().supabase;

  String provider = 'supabase_email_password';
  String accessToken = '';
  String idToken = '';
  String userId = '';

  // Single Loader flag for all validations
  var isLoading = false.obs;

  var isOTPInvalid = false.obs;
  var isOtpInputStarted = false.obs;
  var registeredNumber = ''.obs;
  var metaData = {};

  // OTP Value Storage
  RxString otp = ''.obs;
  RxString email = ''.obs;
  RxString password = ''.obs;
  String fcmToken = '';
  String deviceType = Platform.isIOS ? 'ios' : 'android';
  String deviceId = '';

  // Validators
  void validateEmail() {
    final email = emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    isEmailValid.value = emailRegex.hasMatch(email);
  }

  setDeviceId(String id) {
    deviceId = id;
    update();
  }

  void validatePassword() {
    password.value = passwordController.text;
    debugPrint("user password: $password");

    isPasswordValid.value = password.isNotEmpty && password.value.length >= 8;
  }

  setProviderToNormal() {
    provider = 'supabase_email_password';
    accessToken = '';
    idToken = '';
    update();
  }

  setFCMToken(String token) {
    fcmToken = token;
    update();
  }

  // OTP completion logic

  void isUserInputOtp(TextEditingController controller) {
    isOtpInputStarted.value = controller.text.isNotEmpty;
    update();
  }

  storeEmail(String email) {
    this.email.value = email;
    update();
  }

  // Clear Values
  clearTextFieldsValues() {
    provider = 'supabase_email_password';
    accessToken = '';
    idToken = '';
    update();
  }

  Future<void> onPhoneOtpCompleted(bool success, String message) async {
    if (!success) {
      isOTPInvalid.value = true; // OTP is incorrect
      Future.delayed(Duration(seconds: 1), () {
        otpController.clear(); // Clear OTP input after delay
        isOTPInvalid.value = false; // Reset the error state
        isOtpInputStarted.value =
            false; // Show the resend/validation text again
      });
    } else {
      isOTPInvalid.value = false; // OTP is correct
    }
  }

  String maskNumber(String numStr) {
    if (numStr.length <= 2) {
      return numStr; // If the number has 2 or fewer digits, return it as is
    }
    String masked = '*' * (numStr.length - 2); // Mask all but the last 2 digits
    return masked +
        numStr.substring(numStr.length - 2); // Append the last 2 digits
  }

  // Mock API request for OTP validation
  // Clear all fields
  void clearAllFields() {
    emailController.clear();
    passwordController.clear();
    otpController.clear();
    isEmailValid.value = false;
    isPasswordValid.value = false;
    isChangePassOtpInvalid.value = false;
    isOTPInvalid.value = false;
    email.value = '';
    password.value = '';
    otp.value = '';
    registeredNumber.value = '';
    metaData = {};
    userId = '';
    fcmToken = '';
    update();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.onClose();
  }

  //Queries

  Future<bool> sendOtpForSignIn(String email, String password) async {
    isLoading.value = true; // Start loading
    update();
    try {
      final result = await OnBoardingGQLQueries.sendOtpForSignIn(
          email, password, provider, idToken, accessToken);
      final response = result['data']['sendOtpForSignIn'];
      bool success = response['success'];
      final metadataString = response['metadata'];

      if (success) {
        isLoading.value = true;
        final Map<String, dynamic> metadata = jsonDecode(metadataString);
        if (metadata["mobile"].startsWith('+91')) {
          registeredNumber.value =
              metadata["mobile"].substring(3); // Remove the first 3 characters
        } else if (metadata["mobile"].startsWith('+1')) {
          registeredNumber.value =
              metadata["mobile"].substring(2); // Remove the first 2 characters
        }
        isLoading.value = false; // Stop loading
        return true;
      } else {
        isLoading.value = true;
        HapticFeedbacks.vibrate(FeedbackTypes.error);
        isLoading.value = false;
        showCustomSnackbar('Oops!', response['message']);

        return false;
      }
    } catch (e) {
      isLoading.value = false;
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false;
    }
    // finally {
    //   isLoading.value = false; // Stop loading
    // }
  }

  // Method to verify sign-in OTP
  Future<bool> verifySignInOtp() async {
    isLoading.value = true; // Start loading
    try {
      final result = await OnBoardingGQLQueries.verifySignInOtp(
          deviceId,
          fcmToken,
          deviceType,
          email.value.trim(),
          otpController.text.trim(),
          password.value.trim(),
          provider,
          idToken,
          accessToken);
      final response = result['data']['verifySignInOtp'];
      prints('148ssd: $response');
      bool success = response['success'];
      String message = response['message'];

      final metadataString = response['metadata']; // metadata is a JSON string

      // Decode the JSON string to get a Map
      final data = metadataString == null ? {} : jsonDecode(metadataString);

      if (success) {
        metaData = data;
        isLoading.value = false;
        isOTPInvalid.value = false;
        return true;
      } else {
        isLoading.value = false;
        onPhoneOtpCompleted(success, response['message']);
        HapticFeedbacks.vibrate(FeedbackTypes.error);
        showCustomSnackbar('Oops!', message);
        return false;
      }
    } catch (e) {
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false; // Return failure
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  setUserData() async {
    try {
      // Extract the user and tokens from metadata
      final user = metaData['user'] ?? {};
      final String token = metaData['token'] ?? '';
      final String refreshToken = metaData['refresh_token'] ?? '';
      final String expiresIn = metaData['expires_in']?.toString() ?? '';
      final String expiresAt = metaData['expires_at']?.toString() ?? '';

      debugPrint("user : $user"); // user details
      debugPrint("token : $token"); // token
      debugPrint("refresh_token : $refreshToken");
      debugPrint("expires_in : $expiresIn");
      debugPrint("expires_at : $expiresAt");

      // Store user data
      await LocalStorage.setUserModel(User.fromJson(user));

      prints('663ssd: ${await LocalStorage.getUserModel()}');

      // Store token data
      await LocalStorage.setGraphQLApiToken(token);
      await LocalStorage.setRefreshToken(refreshToken);
      await LocalStorage.setTokenExpiry(expiresIn, expiresAt);

      final response = await supabase.auth.setSession(refreshToken);
      if (response.session == null) {
        throw Exception('Session refresh failed - null session');
      }

      await _saveSession(response.session!);

      //
      clearAllFields();
    } catch (e) {
      debugPrint('Error setting user data: $e');
      rethrow;
    }
  }

  Future<void> _saveSession(sb.Session session) async {
    debugPrint('73ssd: Saving new session data');
    await LocalStorage.setAllTokenData(
      token: session.accessToken,
      refreshToken: session.refreshToken!,
      expiresIn: session.expiresIn?.toString() ?? '',
      expiresAt: session.expiresAt.toString(),
    );

    await LocalStorage.setSession(session);
    debugPrint(
        '79ssd: Session data saved successfully with refresh token ${session.refreshToken}');
  }

  void prints(var s1) {
    String s = s1.toString();
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
  }
}
