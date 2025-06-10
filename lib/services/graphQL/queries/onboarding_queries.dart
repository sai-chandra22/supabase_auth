import '../graphql_service.dart';
import 'package:flutter/foundation.dart';

import '../unauth_service.dart';

class OnBoardingGQLQueries {
  static final GraphQLService _graphQLService = GraphQLService();
  static final _unAuthGraphQLService = UnAuthGraphQLService();

  // Send OTP for SignIn
  static Future<Map<String, dynamic>> sendOtpForSignIn(
      String email,
      String password,
      String provider,
      String? idToken,
      String? accessToken) async {
    String mutation = '''
    mutation sendOtpForSignIn(\$email: String!, \$password: String!, \$provider: String!, \$idToken: String, \$accessToken: String) {
      sendOtpForSignIn(email: \$email, password: \$password, provider: \$provider, idToken: \$idToken, accessToken: \$accessToken) {
      message
      metadata
      success
      }
    }
    ''';

    final variables = {
      'email': email,
      'password': password,
      'provider': provider,
      'idToken': idToken,
      'accessToken': accessToken
    };

    final response = await _graphQLService.performMutation(
        mutation, variables, 'sendOtpForSignIn');

    debugPrint('Response from GraphQL API: $response');

    return response;
  }

  // Verify SignIn OTP
  static Future<Map<String, dynamic>> verifySignInOtp(
      String deviceId,
      String fcmToken,
      String deviceType,
      String email,
      String otp,
      String password,
      String provider,
      String? idToken,
      String? accessToken) async {
    String mutation = '''
    mutation verifySignInOtp(\$email: String!, \$otp: String!, \$password: String!, \$provider: String!, \$idToken: String, \$accessToken: String${fcmToken.isNotEmpty ? ', \$fcmToken: String!' : ''},\$deviceType: String, \$deviceId: String) {
      verifySignInOtp(email: \$email, otp: \$otp, password: \$password, provider: \$provider, idToken: \$idToken, accessToken: \$accessToken${fcmToken.isNotEmpty ? ', fcmToken: \$fcmToken' : ''}, deviceType: \$deviceType, deviceId: \$deviceId) {
      message
      metadata
      success
      }
    }
    ''';

    final variables = {
      'email': email,
      'otp': otp,
      'password': password,
      'provider': provider,
      'idToken': idToken,
      'accessToken': accessToken,
      if (fcmToken.isNotEmpty) 'fcmToken': fcmToken,
      'deviceType': deviceType,
      'deviceId': deviceId
    };

    final response = await _graphQLService.performMutation(
        mutation, variables, 'verifySignInOtp');

    return response;
  }

  static Future<Map<String, dynamic>> saveTestLog(
    String logData,
    String currentToken,
    String name,
  ) async {
    String mutation = '''
    mutation saveTestLog(\$logData: String!, \$currentToken: String!, \$name: String!) {
      saveTestLog(logData: \$logData, currentToken: \$currentToken, name: \$name) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {
      'logData': logData,
      'currentToken': currentToken,
      'name': name
    };

    final response = await _unAuthGraphQLService.performMutation(
        mutation, variables, 'saveTestLog');

    debugPrint('Response from GraphQL API for delete: $response');

    return response;
  }
}
