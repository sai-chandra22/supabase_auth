import '../graphql_service.dart';
import 'package:flutter/foundation.dart';

class UpdateUserGQLQueries {
  static final GraphQLService _graphQLService = GraphQLService();

  // Query to fetch news
  // Method to fetch news present in artist profile
  Future<Map<String, dynamic>> getUserDetails(String artistId) async {
    String query = '''
    query getSimilarArtists(\$artistId: String!){
     getSimilarArtists(artistId: \$artistId) {
      message
      metadata
      success
  }
    }
    ''';

    debugPrint("Inside get similar artists in artist profile");
    final variables = {'artistId': artistId};

    final response = await _graphQLService.performMutation(
        query, variables, 'getSimilarArtists');

    return response;
  }

  Future<Map<String, dynamic>> updateUserDetails(
      //  String userId,
      String email,
      String mobile,
      String firstName,
      String lastName,
      String city,
      String state,
      String street,
      String zipCode,
      String otp,
      bool enableEmailNotifications,
      bool enablePushNotifications) async {
    String mutation = '''
    mutation updateUser(\$email: String!,\$mobile: String!,\$firstName: String!, \$lastName: String!,\$city: String!,\$state: String!,\$street: String!,\$zipCode: String!,\$otp: String!,\$enableEmailNotification: Boolean!,\$enablePushNotification: Boolean!) {
      updateUser(email: \$email, mobile: \$mobile, firstName: \$firstName, lastName: \$lastName, city: \$city, state: \$state, street: \$street, zipCode: \$zipCode, otp: \$otp, enableEmailNotification: \$enableEmailNotification, enablePushNotification: \$enablePushNotification) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {
      // 'userId': userId,
      'email': email,
      'mobile': mobile,
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'state': state,
      'street': street,
      'zipCode': zipCode,
      'otp': otp,
      'enableEmailNotification': enableEmailNotifications,
      'enablePushNotification': enablePushNotifications
    };

    final response = await _graphQLService.performMutation(
        mutation, variables, 'updateUser');

    debugPrint('Response from GraphQL API for delete: $response');

    return response;
  }

  Future<Map<String, dynamic>> updateUserEmailPreferences(
      bool enableEmailNotifications) async {
    String mutation = '''
    mutation updateUser(\$enableEmailNotification: Boolean!,) {
      updateUser(enableEmailNotification: \$enableEmailNotification) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {
      // 'userId': userId,
      'enableEmailNotification': enableEmailNotifications,
    };

    final response = await _graphQLService.performMutation(
        mutation, variables, 'updateUser');

    debugPrint('Response from GraphQL API for delete: $response');

    return response;
  }

  Future<Map<String, dynamic>> updateUserNotificationPreferences(
      bool enablePushNotifications) async {
    String mutation = '''
    mutation updateUser(\$enablePushNotification: Boolean!) {
      updateUser( enablePushNotification: \$enablePushNotification) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {'enablePushNotification': enablePushNotifications};

    final response = await _graphQLService.performMutation(
        mutation, variables, 'updateUser');

    debugPrint('Response from GraphQL API for delete: $response');

    return response;
  }
}
