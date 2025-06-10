import '../graphql_service.dart';
import 'package:flutter/foundation.dart';

import '../unauth_service.dart';

class OnBoardingGQLQueries {
  static final GraphQLService _graphQLService = GraphQLService();
  static final _unAuthGraphQLService = UnAuthGraphQLService();

  // Mutation to send invite code via email

  // SignIn OTP Request for Email
  static Future<Map<String, dynamic>> requestOtpForSignInEmail(
      String email) async {
    String mutation = '''
    mutation requestOtp(\$source: String!) {
      requestOtp(source: \$source, eventType: "email", actionName: "signin") {
        success
        message
      }
    }
    ''';

    final variables = {'source': email};

    final response = await _graphQLService.performMutation(
        mutation, variables, 'requestOtp');

    return response;
  }

  // SignIn OTP Request for Phone
  static Future<Map<String, dynamic>> requestOtpForSignInPhone(
      String phone) async {
    String mutation = '''
    mutation requestOtp(\$source: String!) {
      requestOtp(source: \$source, eventType: "sms", actionName: "signin") {
        success
        message
      }
    }
    ''';

    final variables = {'source': phone};

    final response = await _graphQLService.performMutation(
        mutation, variables, 'requestOtp');

    return response;
  }

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

  static Future<Map<String, dynamic>> doesUserExistByEmail(
      String email, String type, String whereClause) async {
    String mutation = '''
  mutation doesUserExist(\$source: String!, \$type: String!, \$whereClause: String!) {
    doesUserExist(source: \$source, type: \$type, whereClause: \$whereClause) {
      message
      metadata
      success
    }
  }
  ''';

    // Define the variables for the mutation
    final variables = {
      'source': email,
      'type': type,
      'whereClause': whereClause // You can adjust this value if needed
    };

    final response = await _graphQLService.performMutation(
        mutation, variables, 'doesUserExist');

    debugPrint('308ssd: $response');

    // Call the GraphQL service to perform the mutation
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
