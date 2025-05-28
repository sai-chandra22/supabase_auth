import '../../../modules/home_screen/view/home_screen.dart';
import '../graphql_service.dart';
import 'package:flutter/foundation.dart';

import '../unauth_service.dart';

class OnBoardingGQLQueries {
  static final GraphQLService _graphQLService = GraphQLService();
  static final _unAuthGraphQLService = UnAuthGraphQLService();

  // Mutation to send invite code via email
  static Future<Map<String, dynamic>> sendInviteCode(
      String email, String firstName, String lastName) async {
    String mutation = '''
  mutation inviteUser(\$email: String!, \$firstName: String!, \$lastName: String!) {
    inviteUser(email: \$email, firstName: \$firstName, lastName: \$lastName) {
      message
      metadata
      success
    }
  }
  ''';

    final variables = {
      'email': email,
      'firstName': firstName,
      'lastName': lastName
    };

    final response = await _graphQLService.performMutation(
        mutation, variables, 'inviteUser');

    return response;
  }

  // Mutation to verify invite code
  static Future<Map<String, dynamic>> verifyInviteCode(
      String email, String code) async {
    String mutation = '''
    mutation verifyInviteCode(\$email: String!, \$code: String!) {
      verifyInviteCode(email: \$email, code: \$code) {
      message
      metadata
      success
      }
    }
    ''';

    final variables = {
      'email': email,
      'code': code,
    };

    return _graphQLService.performMutation(
        mutation, variables, 'verifyInviteCode');
  }

  // SignUp OTP Request for Email
  static Future<Map<String, dynamic>> requestOtpForSignUpEmail(
      String email) async {
    String mutation = '''
    mutation requestOtp(\$source: String!) {
      requestOtp(source: \$source, eventType: "email", actionName: "signup") {
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

  // SignUp OTP Request for Phone
  static Future<Map<String, dynamic>> requestOtpForSignUpPhone(
      String phone) async {
    String mutation = '''
    mutation requestOtp(\$source: String!) {
      requestOtp(source: \$source, eventType: "sms", actionName: "signup") {
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

  // Forgot Password OTP Request for Email
  static Future<Map<String, dynamic>> requestOtpForForgotPassword(
      String email) async {
    String mutation = '''
    mutation requestOtp(\$source: String!) {
      requestOtp(source: \$source, eventType: "email", actionName: "forgotPassword") {
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

  // SignUp OTP Verification for Email
  static Future<Map<String, dynamic>> verifyOtpForSignUpEmail(
      String email, String otp) async {
    String mutation = '''
    mutation verifyOtp(\$source: String!, \$otp: String!) {
      verifyOtp(source: \$source, eventType: "email", actionName: "signup", otp: \$otp) {
        success
        message
      }
    }
    ''';

    final variables = {
      'source': email,
      'otp': otp,
    };

    final response =
        await _graphQLService.performMutation(mutation, variables, 'verifyOtp');

    return response;
  }

  // SignUp OTP Verification for Phone
  static Future<Map<String, dynamic>> verifyOtpForSignUpPhone(
      String phone, String otp) async {
    String mutation = '''
    mutation verifyOtp(\$source: String!, \$otp: String!) {
      verifyOtp(source: \$source, eventType: "sms", actionName: "signup", otp: \$otp) {
        success
        message
      }
    }
    ''';

    final variables = {
      'source': phone,
      'otp': otp,
    };

    final response =
        await _graphQLService.performMutation(mutation, variables, 'verifyOtp');

    return response;
  }

  // Forgot Password OTP Verification for Email
  static Future<Map<String, dynamic>> verifyOtpForForgotPassword(
      String email, String otp) async {
    String mutation = '''
    mutation verifyOtp(\$source: String!, \$otp: String!) {
      verifyOtp(source: \$source, eventType: "email", actionName: "forgotPassword", otp: \$otp) {
      message
      metadata
      success
      }
    }
    ''';

    final variables = {
      'source': email,
      'otp': otp,
    };

    final response =
        await _graphQLService.performMutation(mutation, variables, 'verifyOtp');

    return response;
  }

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

  // SignUp User

  static Future<Map<String, dynamic>> signUpUser(
      String deviceId,
      String fcmToken,
      String deviceType,
      bool enablePushNotifications,
      bool enableEmailNotifications,
      String email,
      String mobile,
      String? password,
      String provider,
      String? accessToken,
      String idToken,
      String firstName,
      String? lastName,
      {String? scn}) async {
    // Build the mutation string
    String mutation = '''
  mutation signUpUser( \$enablePushNotification: Boolean!, \$enableEmailNotification: Boolean!, \$email: String!, \$mobile: String!, \$password: String, \$provider: String!, \$accessToken: String, \$idToken: String!, \$firstName: String!, \$lastName: String${scn != null ? ', \$scn: String' : ''}${fcmToken.isNotEmpty ? ', \$fcmToken: String!' : ''}, \$deviceType: String, \$deviceId: String) {
    signUpUser(email: \$email, mobile: \$mobile, password: \$password, provider: \$provider, accessToken: \$accessToken, idToken: \$idToken, firstName: \$firstName, lastName: \$lastName, enablePushNotification: \$enablePushNotification, enableEmailNotification: \$enableEmailNotification${scn != null ? ', scn: \$scn' : ''}${fcmToken.isNotEmpty ? ', fcmToken: \$fcmToken' : ''}, deviceType: \$deviceType, deviceId: \$deviceId) {
      message
      metadata
      success
    }
  }
  ''';

    // Prepare the variables map, including `scn` only if it's not null
    final variables = {
      'email': email,
      'mobile': mobile,
      'password': password,
      'provider': provider,
      'firstName': firstName,
      'lastName': lastName,
      'enablePushNotification': enablePushNotifications,
      'enableEmailNotification': enableEmailNotifications,
      if (scn != null) 'scn': scn,
      if (fcmToken.isNotEmpty) 'fcmToken': fcmToken,
      'deviceType': deviceType,
      'deviceId': deviceId,
      'accessToken': accessToken,
      'idToken': idToken,
    };

    prints('idToken: $idToken');

    final response = await _graphQLService.performMutation(
        mutation, variables, 'signUpUser');

    // Perform the mutation
    return response;
  }

  // static Future<Map<String, dynamic>> signUpUser(
  //     bool enablePushNotifications,
  //     bool enableEmailNotifications,
  //     String email,
  //     String mobile,
  //     String? password,
  //     String provider,
  //     String? accessToken,
  //     String idToken,
  //     String firstName,
  //     String? lastName,
  //     {String? scn}) async {
  //   // Build the mutation string
  //   String mutation = '''
  // mutation signUpUser( \$enablePushNotification: Boolean!, \$enableEmailNotification: Boolean!, \$email: String!, \$mobile: String!, \$provider: String!, \$accessToken: String, \$idToken: String!, \$firstName: String!, \$lastName: String${scn != null ? ', \$scn: String' : ''}${password!.isNotEmpty ? ', \$password: String' : ''}) {
  //   signUpUser(email: \$email, mobile: \$mobile,provider: \$provider, accessToken: \$accessToken, idToken: \$idToken, firstName: \$firstName, lastName: \$lastName, enablePushNotification: \$enablePushNotification, enableEmailNotification: \$enableEmailNotification${scn != null ? ', scn: \$scn' : ''}${password.isNotEmpty ? ', password: \$password' : ''}) {
  //     success
  //     message
  //     metadata
  //   }
  // }
  // ''';

  //   // Prepare the variables map, including `scn` only if it's not null
  //   final variables = {
  //     'email': email,
  //     'mobile': mobile,
  //     if (password.isNotEmpty) 'password': password,
  //     'provider': provider,
  //     'accessToken': accessToken,
  //     'idToken': idToken,
  //     'firstName': firstName,
  //     'lastName': lastName,
  //     'enablePushNotification': enablePushNotifications,
  //     'enableEmailNotification': enableEmailNotifications,
  //     if (scn != null) 'scn': scn,
  //   };

  //   // Perform the mutation
  //   return _graphQLService.performMutation(mutation, variables, 'signUpUser');
  // }

  // static Future<Map<String, dynamic>> signUpUser(
  //     String email,
  //     String mobile,
  //     String? password,
  //     String provider,
  //     String? accessToken,
  //     String idToken,
  //     String firstName,
  //     String? lastName) async {
  //   String mutation = '''
  // mutation signUpUser(\$email: String!, \$mobile: String!, \$password: String, \$provider: String!, \$accessToken: String, \$idToken: String!, \$firstName: String!, \$lastName: String) {
  //   signUpUser(email: \$email, mobile: \$mobile, password: \$password, provider: \$provider, accessToken: \$accessToken, idToken: \$idToken, firstName: \$firstName, lastName: \$lastName) {
  //     success
  //     message
  //     metadata
  //   }
  // }
  // ''';

  //   final variables = {
  //     'email': email,
  //     'mobile': mobile,
  //     'password': password,
  //     'provider': provider,
  //     'accessToken': accessToken,
  //     'idToken': idToken,
  //     'firstName': firstName,
  //     'lastName': lastName
  //   };

  //   return _graphQLService.performMutation(mutation, variables, 'signUpUser');
  // }

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

  static Future<Map<String, dynamic>> deleteUserAccount() async {
    String mutation = '''
    mutation deleteUserAccount {
      deleteUserAccount {
      message
      metadata
      success
      }
    }
    ''';

    Map<String, dynamic> variables = {};

    final response = await _graphQLService.performMutation(
        mutation, variables, 'deleteUserAccount');

    debugPrint('Response from GraphQL API for delete: $response');

    return response;
  }

  static Future<Map<String, dynamic>> signOutUser(String authToken) async {
    // Define the GraphQL mutation string for signing out the user
    String mutation = '''
    mutation signOutUser(\$authToken: String!) {
      signOutUser(authToken: \$authToken) {
        message
        metadata
        success
      }
    }
  ''';

    debugPrint('425ssd val: $mutation');

    // Prepare the variables, in this case, the authToken
    final variables = {'authToken': authToken};

    // Call the GraphQL service's mutation method with the mutation and variables
    final response = await _graphQLService.performMutation(
        mutation, variables, 'signOutUser');

    // Log the response from the API for debugging purposes
    debugPrint('Response from GraphQL API for sign out: $response');

    // Return the response to be used elsewhere in the code
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

  static Future<Map<String, dynamic>> getInvestorByScn(String scn) async {
    // Define the GraphQL query string for retrieving investor details by SCN
    String mutation = '''
    mutation getInvestorByScn(\$scn: String!) {
      getInvestorByScn(scn: \$scn) {
        message
        metadata
        success
      }
    }
  ''';

    // Prepare the variables, in this case, the SCN
    final variables = {'scn': scn};

    // Call the GraphQL service's query method with the query and variables
    final response = await _graphQLService.performMutation(
        mutation, variables, 'getInvestorByScn');

    // Log the response from the API for debugging purposes
    debugPrint('Response from GraphQL API for getInvestorByScn: $response');

    // Return the response to be used elsewhere in the code
    return response;
  }

  static Future<Map<String, dynamic>> updateUserPassword(
    String email,
    String password,
  ) async {
    String mutation = '''
    mutation updateUserPassword(\$email: String!, \$password: String!) {
      updateUserPassword(email: \$email, password: \$password) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {'email': email, 'password': password};

    final response = await _graphQLService.performMutation(
        mutation, variables, 'updateUserPassword');

    debugPrint('Response from GraphQL API for delete: $response');

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
