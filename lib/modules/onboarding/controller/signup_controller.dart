import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mars_scanner/services/graphQL/queries/onboarding_queries.dart';
import 'package:mars_scanner/services/keys/api_keys.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../cache/local/secured_storage.dart';
import '../../../cache/local/shared_prefs.dart';
import '../../../helpers/custom_snackbar.dart';
import '../../../helpers/decode.dart';
import '../../../helpers/haptics.dart';
//import '../../../services/auth/token_expiry_manager.dart';
import '../../../services/auth/token_expiry_manager.dart';
import '../model/user_model.dart';

class SignUpController extends GetxController {
  // PageController for the PageView
  PageController pageController = PageController();

  // Track the current page index
  var currentPage = 0.obs;
  static const String countryCode = '+1';
  Map<String, dynamic>? metaData = {};
  String? idToken;
  String? accessToken;
  String? appleIdToken;
  String? nonce;
  String provider = 'supabase_email_password';
  String name = 'Me';
  bool isNotificationEnabled = false;
  String fcmToken = '';
  String deviceType = Platform.isIOS ? 'ios' : 'android';
  String deviceId = '';

  // Form Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController inviteCodeMailController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController shareHolderController = TextEditingController();

  final supabase = TokenExpiryManager().supabase;

  // Pinput Controllers for OTP input
  TextEditingController emailOtpController =
      TextEditingController(); // Email OTP Controller
  TextEditingController phoneOtpController =
      TextEditingController(); // Phone OTP Controller

  RxString emailOtp = ''.obs; // To store OTP input for email
  RxString phoneOtp = ''.obs; // To store OTP input for phone
  String storeMailId = '';
  String storeFirstName = '';
  String storeLastName = '';
  RxString signUpEmail = ''.obs;
  RxString signUpPhone = ''.obs;
  RxString password = ''.obs;
  RxString signUpFirstName = ''.obs;
  RxString signUpLastName = ''.obs;
  RxString signUpSCNEmail = ''.obs;
  RxString shareHolderNumber = ''.obs;
  RxString inviteEmailAddress = ''.obs;
  bool isChanged = false;
  var isButtonDisabled = false.obs;

  // Validation status
  var isEmailValid = false.obs;
  var isInviteEmailValid = false.obs;
  var isPhoneValid = false.obs;
  var isPasswordValid = false.obs;
  var isTnCAccepted = false.obs;
  var allowNotifications = true.obs;
  var optMessaging = false.obs;
  var isFirstNameValid = false.obs;
  var isLastNameValid = false.obs;
  var isShareHolderValid = false.obs;

  var implementDoubleText = false.obs;

  var isOTPInvalid = false.obs;
  var isOtpInputStarted = false.obs;

  // OTP validation status
  var isEmailOtpValid = false.obs;
  var isPhoneOtpValid = false.obs;

  // Single Loader flag for all validations
  var isLoading = false.obs;

  // Password validation breakdown
  var isPasswordLengthValid = false.obs;
  var hasUpperLowerCase = false.obs;
  var hasNumber = false.obs;
  var hasSpecialCharacter = false.obs;
  var makeKeyBoardInactive = false.obs;

  toggleKeyBoardActivity(bool value) {
    makeKeyBoardInactive.value = value;
    update();
  }

  toggleDisability(bool value) {
    isButtonDisabled.value = value;
    update();
  }

  setFCMToken(String token) {
    fcmToken = token;
    update();
  }

  setDeviceId(String id) {
    deviceId = id;
    update();
  }

  updateOptMessaging() {
    optMessaging.value = !optMessaging.value;
    update();
  }

  updateIsChanged() {
    isChanged = !isChanged;
    debugPrint("isChanged: $isChanged");
    update();
  }

  setProviderToNormal() {
    provider = 'supabase_email_password';
    update();
  }

  void setTNCButtonActive() {
    isTnCAccepted.value = true;
    update();
  }

  void setDoubleTextTrue() {
    implementDoubleText.value = true;
    update();
  }

  void setDoubleTextFalse() {
    implementDoubleText.value = false;
    update();
  }

  clearShareHolderText() {
    shareHolderController.clear();
    update();
  }

  // Validators
  void validateEmail() {
    final email = emailController.text;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    isEmailValid.value = emailRegex.hasMatch(email);
  }

  void validateFirstName() {
    final firstName = firstNameController.text;
    isFirstNameValid.value = firstName.length >= 3;
    update();
  }

  void validateLastName() {
    final firstName = lastNameController.text;
    isLastNameValid.value = firstName.isNotEmpty;
    update();
  }

  void validateInviteEmail() {
    final email = inviteCodeMailController.text;
    inviteEmailAddress.value = email;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    isInviteEmailValid.value = emailRegex.hasMatch(email);
    debugPrint("isInviteEmailValid.value: ${isInviteEmailValid.value}");
    update();
  }

  void validateShareHolder(String shareHolderText) {
    final shareHolder = shareHolderText;
    isShareHolderValid.value = shareHolder.length >= 2;
    update();
  }

  void validatePhoneNumber() {
    final phoneNumber = phoneController.text;
    final phoneRegex =
        RegExp(r'^\d{3}-\d{3}-\d{4}$'); // Example: 10-digit phone number
    isPhoneValid.value = phoneRegex.hasMatch(phoneNumber) && optMessaging.value;
  }

  void validatePassword() {
    final password = passwordController.text;
    isPasswordLengthValid.value = password.length >= 8 && password.length <= 32;
    hasUpperLowerCase.value = password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]'));
    hasNumber.value = password.contains(RegExp(r'[0-9]'));
    hasSpecialCharacter.value =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    isPasswordValid.value = isPasswordLengthValid.value &&
        hasUpperLowerCase.value &&
        hasNumber.value &&
        hasSpecialCharacter.value;
  }

  void isUserInputOtp(TextEditingController controller) {
    isOtpInputStarted.value = controller.text.isNotEmpty;
    update();
  }

  Future<void> onEmailOtpCompleted(bool success) async {
    if (!success) {
      // Assume "1234" is the valid OTP for demonstration
      isOTPInvalid.value = true; // OTP is incorrect
      isEmailOtpValid.value = false;
      Future.delayed(Duration(seconds: 1), () {
        emailOtpController.clear(); // Clear OTP input after delay
        isOTPInvalid.value = false; // Reset the error state
        isOtpInputStarted.value =
            false; // Show the resend/validation text again
      });
    } else {
      isOTPInvalid.value = false; // OTP is correct
      isEmailOtpValid.value = true;
    }
  }

  Future<void> onPhoneOtpCompleted(
    bool success,
  ) async {
    if (!success) {
      // Assume "1234" is the valid OTP for demonstration
      isOTPInvalid.value = true; // OTP is incorrect
      isPhoneOtpValid.value = false;
      Future.delayed(Duration(seconds: 1), () {
        phoneOtpController.clear(); // Clear OTP input after delay
        isOTPInvalid.value = false; // Reset the error state
        isOtpInputStarted.value =
            false; // Show the resend/validation text again
      });
    } else {
      isOTPInvalid.value = false; // OTP is correct
      isPhoneOtpValid.value = true;
    }
  }

  // Navigate to the next page
  void nextPage() {
    if (pageController.hasClients && currentPage.value < 1) {
      currentPage.value++;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.175, 0.885, 0.32, 1.22),
      );
    }
  }

  setTnCValueToTrue() {
    isTnCAccepted.value = true;
  }

  // Navigate to the previous page
  void previousPage() {
    if (pageController.hasClients && currentPage.value > 0) {
      currentPage.value--;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.175, 0.885, 0.32, 1.22),
      );
    }
  }

  void clearInviteMailText() {
    inviteCodeMailController.clear();
    firstNameController.clear();
    lastNameController.clear();
    inviteEmailAddress.value = '';
    isInviteEmailValid.value = false;
    isFirstNameValid.value = false;
    isLastNameValid.value = false;
    update();
  }

  void clearAllFields() {
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    emailOtpController.clear();
    phoneOtpController.clear();
    shareHolderController.clear();
    isEmailOtpValid.value = false;
    isPhoneOtpValid.value = false;
    isEmailValid.value = false;
    isPhoneValid.value = false;
    isPasswordValid.value = false;
    isPasswordLengthValid.value = false;
    hasUpperLowerCase.value = false;
    hasNumber.value = false;
    hasSpecialCharacter.value = false;
    isTnCAccepted.value = false;
    isOtpInputStarted.value = false;
    isInviteEmailValid.value = false;
    signUpEmail.value = '';
    signUpPhone.value = '';
    password.value = '';
    firstNameController.clear();
    lastNameController.clear();
    inviteCodeMailController.clear();
    signUpFirstName.value = '';
    signUpLastName.value = '';
    isFirstNameValid.value = false;
    isLastNameValid.value = false;
    isChanged = false;
    shareHolderNumber.value = '';
    optMessaging.value = false;
    fcmToken = '';

    update();
  }

  clearTextFields() {
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    emailOtpController.clear();
    phoneOtpController.clear();
    shareHolderController.clear();
    isEmailOtpValid.value = false;
    isPhoneOtpValid.value = false;
    isEmailValid.value = false;
    isPhoneValid.value = false;
    isPasswordValid.value = false;
    isPasswordLengthValid.value = false;
    hasUpperLowerCase.value = false;
    hasNumber.value = false;
    hasSpecialCharacter.value = false;
    isTnCAccepted.value = false;
    isOtpInputStarted.value = false;
    signUpPhone.value = '';
    optMessaging.value = false;
    isButtonDisabled.value = false;
    isFirstNameValid.value = false;
    isLastNameValid.value = false;
    update();
  }

  @override
  void onClose() {
    pageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    emailOtpController.dispose(); // Dispose OTP controllers
    phoneOtpController.dispose();
    inviteCodeMailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    shareHolderController.dispose();
    super.onClose();
  }

  //queries

  Future<void> saveEmailToLocalStorage(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('inviteCodeEmail', email);
    storeMailId = email;
  }

  Future<String?> getEmailFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('inviteCodeEmail');
  }

  Future<void> sendInviteCodeMethod(
      String email, String firstName, String lastName,
      [bool? navigate]) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to send the invite code
      final result =
          await OnBoardingGQLQueries.sendInviteCode(email, firstName, lastName);

      // Parse the response
      final response = result['data']['inviteUser'];
      debugPrint('325ssd: $response');
      bool success = response['success'];
      String message = response['message'];

      // Handle success response
      if (success) {
        Get.back();
        isLoading.value = false;
        inviteCodeMailController.clear();
        firstNameController.clear();
        lastNameController.clear();
        inviteEmailAddress.value = '';

        storeMailId = email;
        signUpEmail.value = email;
        storeFirstName = firstName;
        storeLastName = lastName;
        saveEmailToLocalStorage(email);
        update();
        Future.delayed(Duration(milliseconds: 200), () {
          showCustomSnackbar('Success', message); // Use custom snackbar
        });
      } else {
        isLoading.value = false;
        showCustomSnackbar('Ooops!', message);
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
    } finally {
      isLoading.value = false; // Stop loading after the process is complete
    }
  }

  Future<bool> verifyInviteCodeMethod(String email, String code) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to verify the invite code

      final result = await OnBoardingGQLQueries.verifyInviteCode(email, code);

      // Parse the response
      final response = result['data']['verifyInviteCode'];
      debugPrint('370ssd: $response');
      bool success = response['success'];
      String message = response['message'];

      if (success) {
        final metadata = response['metadata'];
        if (metadata != null && metadata != '') {
          Map<String, dynamic> metadataMap = jsonDecode(metadata);
          signUpEmail.value = metadataMap['email'];
          debugPrint('377ssd: $signUpEmail');
        } // Assign email from metadata
        isLoading.value = false; // Stop loading
        return true;
      } else {
        isLoading.value = false;
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

  // Verify ShareHolder

  Future<bool> verifyShareHolder(String code) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to verify the invite code
      final result = await OnBoardingGQLQueries.getInvestorByScn(code);

      // Parse the response
      final response = result['data']['getInvestorByScn'];
      bool success = response['success'];
      String message = response['message'];
      var metaData = response['metadata'];

      if (success) {
        isLoading.value = false; // Stop loading
        if (metaData is String) {
          metaData = jsonDecode(metaData);
        }
        if (metaData != null && metaData != '') {
          shareHolderNumber.value = metaData['scn'].toString();
          signUpSCNEmail.value = metaData['email_address'].toString();
          signUpFirstName.value = metaData['first_name'].toString();
          signUpLastName.value = metaData['last_name'].toString();
          signUpPhone.value = metaData['phone_numbers'].toString();

          debugPrint(
              '402ssd: $shareHolderNumber $signUpSCNEmail $signUpFirstName $signUpLastName $signUpPhone');
          update();
        }
        return true;
      } else {
        isLoading.value = false;
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

  Future<bool> requestOtpForSignUpEmailMethod(String email) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to request OTP for email signup
      provider = 'supabase_email_password';
      accessToken = '';
      idToken = '';
      final result = await OnBoardingGQLQueries.requestOtpForSignUpEmail(email);

      // Parse the response
      final response = result['data']['requestOtp'];
      bool success = response['success'];
      String message = response['message'];

      // Handle success response
      if (success) {
        isLoading.value = false; // Stop loading
        signUpEmail.value = email;
        return true;
      } else {
        isLoading.value = false;
        showCustomSnackbar('Error', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false;
    }
  }

  Future<bool> requestOtpForSignUpPhone(String phone) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to request OTP for phone SignUp
      final phoneWithCountryCode = '$countryCode$phone';
      final result = await OnBoardingGQLQueries.requestOtpForSignUpPhone(
          phoneWithCountryCode);

      // Parse the response
      final response = result['data']['requestOtp'];
      bool success = response['success'];
      String message = response['message'];

      // Handle success response
      if (success) {
        isLoading.value = false; // Stop loading
        signUpPhone.value = phoneWithCountryCode;

        return true;
      } else {
        isLoading.value = false;
        showCustomSnackbar('Error', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false;
    }
  }

  Future<bool> verifyOtpForSignUpEmail(String email, String otp) async {
    isLoading.value = true; // Start loading
    try {
      // Call the GraphQL API to verify OTP for email SignUp
      final result =
          await OnBoardingGQLQueries.verifyOtpForSignUpEmail(email, otp);

      // Parse the response
      final response = result['data']['verifyOtp'];
      bool success = response['success'];

      // Handle success response
      if (success) {
        isLoading.value = false; // Stop loading
        isOTPInvalid.value = false;
        return true; // Return true if the OTP is successfully verified
      } else {
        isLoading.value = false;
        onEmailOtpCompleted(success);
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

  Future<bool> signUpUser([String? scn, String? provider]) async {
    isLoading.value = true; // Start loading

    final authProvider = provider ?? 'supabase_email_password';
    final authAccessToken = accessToken ?? '';
    final authIdToken = idToken ?? '';

    try {
      final result = await OnBoardingGQLQueries.signUpUser(
        deviceId,
        fcmToken,
        deviceType,
        allowNotifications.value,
        true,
        signUpEmail.value,
        signUpPhone.value,
        password.value,
        authProvider,
        authAccessToken,
        authIdToken,
        signUpFirstName.value.isNotEmpty
            ? signUpFirstName.value
            : storeFirstName,
        signUpLastName.value.isNotEmpty ? signUpLastName.value : storeLastName,
        scn: (scn != null && scn.isNotEmpty) ? scn : null,
      );
      final response = result['data']['signUpUser'];

      prints('564ssd response: $response');

      bool success = response['success'];
      String message = response['message'];
      final metadataString = response['metadata']; // metadata is a JSON string

      // Decode the JSON string to get a Map
      final metadata = metadataString == null ? {} : jsonDecode(metadataString);

      // Extract user and token from metadata

      if (success) {
        metaData = metadata;
        isLoading.value = false;

        // showCustomSnackbar('Signed up successfully',
        //     'Your Registration was completed, you can update your profile from settings!'); // Use custom snackbar
        return true;
      } else {
        isLoading.value = false;
        showCustomSnackbar('Oops!', message); // Use custom snackbar
        // isLoading.value = false;
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false;
    } finally {
      isLoading.value = false; // Stop loading
    }
  }

  Future<bool> verifyOtpForSignUpPhone(String phone, String otp) async {
    isLoading.value = true; // Start loading

    try {
      // Call the GraphQL API to verify OTP for phone SignUp
      final result =
          await OnBoardingGQLQueries.verifyOtpForSignUpPhone(phone, otp);

      // Parse the response
      final response = result['data']['verifyOtp'];
      bool success = response['success'];

      // Handle success response
      if (success) {
        isLoading.value = false; // Stop loading
        isOTPInvalid.value = false;
        // phoneOtpController.clear();
        return true; // Return true if the OTP is successfully verified
      } else {
        isLoading.value = false;
        onPhoneOtpCompleted(success);
        showCustomSnackbar('Oops!', response['message']); // Use custom snackbar

        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar('Error', e.toString()); // Use custom snackbar
      return false; // Return false if there was an error
    }
  }

  setUserData([String? scn]) async {
    // Extract the user as a Map, since it's not a list
    final dynamic userMeta = metaData?['user'];
    final user = (userMeta is List && userMeta.isNotEmpty)
        ? userMeta.first
        : userMeta ?? {}; // Handle both List and Map cases
    prints('663ssd: $user');
    final String token = metaData?['token'];
    final String refreshToken = metaData?['refresh_token'] ?? '';
    final String expiresIn = metaData?['expires_in']?.toString() ?? '';
    final String expiresAt = metaData?['expires_at']?.toString() ?? '';

    debugPrint("user : $user"); // user details
    debugPrint("token : $token"); // token
    debugPrint("refresh_token : $refreshToken");
    debugPrint("expires_in : $expiresIn");
    debugPrint("expires_at : $expiresAt");

    // Store user data
    await LocalStorage.setUserModel(User.fromJson(user));

    // Store token data
    await LocalStorage.setGraphQLApiToken(token);
    await LocalStorage.setRefreshToken(refreshToken);
    await LocalStorage.setTokenExpiry(expiresIn, expiresAt);
    //   initializeNotifications();

    final response = await supabase.auth.setSession(refreshToken);
    if (response.session == null) {
      throw Exception('Session refresh failed - null session');
    }

    await _saveSession(response.session!);

    // await TokenExpiryManager().initialize(isAfterAuth: true);

    clearAllFields();
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

  //Google Sign Up

  Future<bool> googleSignUpUser() async {
    debugPrint('502ssd');
    try {
      isLoading.value = true;
      const webClientId =
          //   '660393401499-6u0aenab2jf4gkiqmkgeck0cg4k5st30.apps.googleusercontent.com';
          '1030737876872-7eedi527d3dl3p0f4lp1cvl9grrk8u4d.apps.googleusercontent.com';
      const iosClientId =
          //  '660393401499-elfobiluvs4okp75338h7tg9dtssmo76.apps.googleusercontent.com';
          '1030737876872-lr5u1h134ql3gtg7htgj2ra7obdtntbu.apps.googleusercontent.com';

      // Initialize GoogleSignIn with client IDs
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
        scopes: [
          'email',
        ],
      );

      // Sign out first to force account picker to show
      await googleSignIn.signOut();

      // Attempt to sign in the user
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      signUpEmail.value = googleUser?.email ?? '';
      if (signUpFirstName.isEmpty) {
        signUpFirstName.value = storeFirstName.isNotEmpty
            ? storeFirstName
            : (googleUser?.displayName ?? '');
      }
      if (signUpLastName.isEmpty) {
        signUpLastName.value = storeLastName.isNotEmpty ? storeLastName : ('');
      }

      debugPrint("googleUser: $googleUser");
      update();

      if (googleUser == null) {
        // The user canceled the sign-in
        showCustomSnackbar(
            'Sign-Up Aborted', 'You cancelled the sign-in process.');
        isLoading.value = false;
        return false; // Return false if the sign-in is aborted
      }

      // Retrieve authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      accessToken = googleAuth.accessToken;
      idToken = googleAuth.idToken;

      prints('518ssd: ${googleAuth.accessToken}');
      prints('519ssd: ${googleAuth.idToken}');
      debugPrint('520ssd: ${googleUser.email}');

      // Validate tokens
      if (accessToken == null || idToken == null) {
        showCustomSnackbar(
          'Sign-Up Failed',
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
      debugPrint('Google Sign-Up PlatformException: ${e.message}');
      showCustomSnackbar(
        'Sign-Up Failed',
        e.message ?? 'An unknown error occurred.',
      );
      return false; // Return false on error
    } catch (e) {
      isLoading.value = false;
      // Handle any other type of error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      debugPrint('Google Sign-In Error: $e');
      showCustomSnackbar(
        'Sign-Up Failed',
        'An unexpected error occurred.',
      );
      return false; // Return false on error
    }
  }

  Future<bool> doesUserExistByEmail(String email) async {
    isLoading.value = true; // Start loading
    try {
      debugPrint('308ssd: $email');
      // Call the GraphQL API to verify OTP for email SignUp
      final result =
          await OnBoardingGQLQueries.doesUserExistByEmail(email, 'email', '');

      // Parse the response
      final response = result['data']['doesUserExist'];
      bool success = response['success'];
      final message = response['message'];

      // Handle success response
      if (!success && email != '') {
        isLoading.value = false; // Stop loading
        return true;
      } else {
        isLoading.value = false; // Stop loading
        showCustomSnackbar('Sign Up failed!', message);
        return false;
      }
    } catch (e) {
      isLoading.value = false; // Stop loading if there's an error
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar(
          'Sign Up failed!', e.toString()); // Use custom snackbar
      return false; // Return false if there was an error
    }
  }

  //Apple Sign UP

  Future<bool> appleSignUpUser() async {
    try {
      isLoading.value = true;

      // Generate raw nonce and hashed nonce
      nonce = supabase.auth.generateRawNonce();
      update();
      final hashedNonce = sha256.convert(utf8.encode(nonce!)).toString();

      // Get Apple credential
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId:
              ApiKeys.appleClientId, // Service ID from Apple Developer Console
          redirectUri: Uri.parse(ApiKeys.appleRedirectUrl
              // 'signinwithapple://callback'
              ), // Set redirect URI
        ),
      );

      // Retrieve the ID token from the credential
      appleIdToken = credential.identityToken;
      // Get name and email (only available first time)
      String? fullName =
          '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      String? email = credential.email;

      // If the name and email are not available (subsequent sign-ins), retrieve them from secure storage
      if (email == null || email.isEmpty) {
        email = await SecuredStorage
            .getStoredEmail(); // Retrieve email from secure storage
        debugPrint("Apple email: $email");
        fullName = await SecuredStorage
            .getStoredFullName(); // Retrieve full name from secure storage
      } else {
        // Save the email and full name to secure storage for future use
        await SecuredStorage.saveEmail(email);
        await SecuredStorage.saveFullName(fullName);
      }

      // Save the userIdentifier to secure storage
      String userIdentifier = credential.userIdentifier ?? '';
      await SecuredStorage.saveUserIdentifier(userIdentifier);

      List<String> nameParts =
          fullName != null ? fullName.split(' ') : ['', ''];

      // Set the values for the application state
      signUpEmail.value =
          email ?? decodeJWTAndGetEmail(credential.identityToken ?? '') ?? '';
      if (signUpFirstName.isEmpty) {
        signUpFirstName.value = storeFirstName.isNotEmpty
            ? storeFirstName
            : nameParts[0].isEmpty
                ? extractNameFromEmail(signUpEmail.value)
                : nameParts[0];
      }
      if (signUpLastName.isEmpty) {
        signUpLastName.value = storeLastName.isNotEmpty
            ? storeLastName
            : (nameParts.length > 1)
                ? nameParts[1]
                : '';
      }

      accessToken = nonce;
      idToken = appleIdToken;

      prints('778ssd: ${signUpFirstName.value} ${signUpEmail.value}');

      update();

      if (appleIdToken == null) {
        showCustomSnackbar(
          'Sign-Up Failed',
          'Could not find valid ID from generated credentials.',
        );
        isLoading.value = false;
        return false; // Return false if no ID token is found
      }

      isLoading.value = false;
      provider = 'apple';

      // Debugging: debugPrint user information
      prints(
          'User Info: Full Name: $fullName, Email: $email, ID Token: ${credential.identityToken}, User Identifier: ${credential.userIdentifier}');

      return true;
    } on PlatformException catch (e) {
      isLoading.value = false;

      showCustomSnackbar(
        'Sign-Up Failed',
        e.message ?? 'An unknown error occurred.',
      );
      return false;
    } catch (e) {
      isLoading.value = false;
      HapticFeedbacks.vibrate(FeedbackTypes.error);
      showCustomSnackbar(
        'Sign-Up Failed',
        'An unexpected error occurred.',
      );
      return false; // Return false on error
    } finally {
      isLoading.value = false; // Stop loading in all cases
    }
  }

  String extractNameFromEmail(String email) {
    if (email.isEmpty) {
      return "Me";
    }

    // Extract the part before '@'
    String namePart = email.split('@')[0];

    // Remove all special characters, numbers, and dots using regex
    namePart = namePart.replaceAll(RegExp(r'[^a-zA-Z]'), '');

    return namePart;
  }

  void prints(var s1) {
    String s = s1.toString();
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
  }
}
