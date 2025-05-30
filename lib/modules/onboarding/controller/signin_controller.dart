import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mars_scanner/helpers/decode.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../cache/local/shared_prefs.dart';
import '../../../helpers/custom_snackbar.dart';
import '../../../helpers/haptics.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../../../services/graphQL/queries/onboarding_queries.dart';
import '../../../services/keys/api_keys.dart';
import '../../home_screen/controller/home_controller.dart';
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

  //Forgot Password
  Future<bool> requestOtpForForgotPassword(String email) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to request OTP for email signup
      provider = 'supabase_email_password';
      accessToken = '';
      idToken = '';
      final result =
          await OnBoardingGQLQueries.requestOtpForForgotPassword(email);

      // Parse the response
      final response = result['data']['requestOtp'];
      bool success = response['success'];
      String message = response['message'];

      // Handle success response
      if (success) {
        isLoading.value = false; // Stop loading
        return true;
      } else {
        isLoading.value = false;
        HapticFeedbacks.vibrate(FeedbackTypes.error);
        showCustomSnackbar('Oops!', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false;
    }
  }

  Future<bool> verifyOtpForForgotPassword(String email, String otp) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to verify OTP for email SignUp
      final result =
          await OnBoardingGQLQueries.verifyOtpForForgotPassword(email, otp);

      // Parse the response
      final response = result['data']['verifyOtp'];
      bool success = response['success'];

      // Handle success response
      if (success) {
        isLoading.value = false; // Stop loading
        isChangePassOtpInvalid.value = false;

        // final metadata = response['metadata'];

        // if (metadata != null) {
        //   Map<String, dynamic> metadataMap = jsonDecode(metadata);
        //   if (metadataMap.containsKey('id')) {
        //     userId = metadataMap['id'].toString(); // Assign id to userId
        //   }
        // }
        return true; // Return true if the OTP is successfully verified
      } else {
        isLoading.value = false;
        isChangePassOtpInvalid.value = true;
        HapticFeedbacks.vibrate(FeedbackTypes.error);
        // onEmailOtpCompleted(success);
        showCustomSnackbar('Error', response['message']);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false; // Return false if there was an error
    }
  }

  Future<bool> updateUserPassword(String password, String email) async {
    isLoading.value = true; // Start loading
    try {
      final result =
          await OnBoardingGQLQueries.updateUserPassword(email, password);
      final response = result['data']['updateUserPassword'];
      final success = response['success'];
      final message = response['message'];
      if (success) {
        isLoading.value = false;
        clearAllFields();
        showCustomSnackbar('Success', 'Password Updated Successfully');
        return true;
      } else {
        isLoading.value = false;
        HapticFeedbacks.vibrate(FeedbackTypes.error);
        showCustomSnackbar('Oops!', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false; // Return false if there was an error
    }
  }

  Future<bool> deleteUserAccount() async {
    try {
      isLoading.value = true; // Start loading
      debugPrint("userId : $userId");

      final result = await OnBoardingGQLQueries
          .deleteUserAccount(); // Ensure userId is int
      debugPrint('GraphQL result: $result'); // Debug log the entire result

      // Check if 'data' exists in the result
      if (result.isEmpty || result['data'] == null) {
        isLoading.value = false; // Stop loading
        showCustomSnackbar('Error', 'No data received from server');
        return false;
      }

      // Check if 'deleteUserAccount' exists in the response data
      final response = result['data']['deleteUserAccount'];
      if (response == null) {
        isLoading.value = false; // Stop loading
        showCustomSnackbar('Error', 'Invalid response from server');
        return false;
      }

      // Check for success and message in response
      bool success = response['success'] ?? false;
      String message = response['message'] ?? 'Something went wrong';

      if (success) {
        isLoading.value = false; // Stop loading
        showCustomSnackbar('Success', message);
        return true;
      } else {
        isLoading.value = false; // Stop loading
        HapticFeedbacks.vibrate(FeedbackTypes.error);
        showCustomSnackbar('Oops!', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading in case of exception
      debugPrint('Error: $e');
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString());
      return false;
    }
  }

  final homeController = Get.find<HomeController>();

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

  Future<bool> googleSignUpUser() async {
    try {
      isLoading.value = true;
      // Define your OAuth client IDs
      const webClientId =
          //   '660393401499-6u0aenab2jf4gkiqmkgeck0cg4k5st30.apps.googleusercontent.com';
          '1030737876872-7eedi527d3dl3p0f4lp1cvl9grrk8u4d.apps.googleusercontent.com';
      const iosClientId =
          // '660393401499-elfobiluvs4okp75338h7tg9dtssmo76.apps.googleusercontent.com';
          '1030737876872-lr5u1h134ql3gtg7htgj2ra7obdtntbu.apps.googleusercontent.com';

      // Initialize GoogleSignIn with client IDs
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
        scopes: [
          'email',
        ],
      );
      await googleSignIn.signOut();

      // Attempt to sign in the user
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      email.value = googleUser?.email ?? '';
      update();
      debugPrint("googleUser: $googleUser");

      if (googleUser == null) {
        // The user canceled the sign-in
        showCustomSnackbar(
            'Sign-In Aborted', 'You cancelled the sign-in process.');
        isLoading.value = false;
        return false; // Return false if the sign-in is aborted
      }

      // Retrieve authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      accessToken = googleAuth.accessToken ?? '';
      idToken = googleAuth.idToken ?? '';

      prints('518ssd: ${googleAuth.accessToken}');
      prints('519ssd: ${googleAuth.idToken}');
      debugPrint('520ssd: ${googleUser.email}');

      // Validate tokens
      if (accessToken.isEmpty || idToken.isEmpty) {
        showCustomSnackbar(
          'Sign-In Failed',
          'Missing authentication tokens.',
        );
        isLoading.value = false;
        return false; // Return false if tokens are missing
      }

      // Tokens successfully obtained, stop here and return true
      isLoading.value = false;
      provider = 'google';
      update();
      return true; // Return true indicating the tokens were successfully retrieved
    } on PlatformException catch (e) {
      isLoading.value = false;
      // Handle platform-specific errors
      debugPrint('Google Sign-In PlatformException: ${e.message}');
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar(
        'Sign-In Failed',
        e.message ?? 'An unknown error occurred.',
      );
      return false; // Return false on error
    } catch (e) {
      isLoading.value = false;
      // Handle any other type of error
      debugPrint('Google Sign-In Error: $e');
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar(
        'Sign-In Failed',
        'An unexpected error occurred.',
      );
      return false; // Return false on error
    }
  }

  Future<bool> appleSignUpUser() async {
    try {
      isLoading.value = true;

      // Generate raw nonce and hashed nonce
      final nonce = supabase.auth.generateRawNonce();
      update();
      final hashedNonce = sha256.convert(utf8.encode(nonce)).toString();

      // Get Apple credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: ApiKeys.appleClientId,
          redirectUri: Uri.parse(ApiKeys.appleRedirectUrl),
        ),
      );

      // Retrieve the ID token from the credential
      final appleIdToken = credential.identityToken;
      if (credential.email == null) {
        email.value =
            decodeJWTAndGetEmail(credential.identityToken ?? '') ?? '';
      } else {
        email.value = credential.email ?? '';
      }

      accessToken = nonce;
      idToken = credential.identityToken ?? '';

      update();
      if (appleIdToken == null) {
        showCustomSnackbar(
          'Sign-In Failed',
          'Could not find valid ID from generated credentials.',
        );
        isLoading.value = false;
        return false; // Return false if no ID token is found
      }

      isLoading.value = false;
      provider = 'apple';
      prints('appleIdToken: $appleIdToken, nonce: $nonce,  email: $email');
      update();

      return true;
    } on PlatformException catch (e) {
      isLoading.value = false;
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar(
        'Sign-In Failed',
        e.message ?? 'An unknown error occurred.',
      );
      return false;
    } catch (e) {
      isLoading.value = false;
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar(
        'Sign-In Failed',
        'An unexpected error occurred.',
      );
      return false; // Return false on error
    }
  }

  // Signout User
  Future<bool> signOutUser(String authToken) async {
    try {
      isLoading.value = true;
      final response = await OnBoardingGQLQueries.signOutUser(authToken);

      final result = response['data']['signOutUser'];

      bool success = result['success'];
      //  final message = result['message'];

      if (success) {
        isLoading.value = false;
        return true;
      } else {
        isLoading.value = false;

        //  showCustomSnackbar('Sign-Out Failed', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      return false; // Return false on error
    }
  }

  void prints(var s1) {
    String s = s1.toString();
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
  }
}
