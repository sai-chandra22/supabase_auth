import 'package:mars_scanner/services/graphQL/graphql_service.dart';

class EventQueries {
  static final GraphQLService _graphQLService = GraphQLService();

  // Query to validate a barcode
  static Future<Map<String, dynamic>> validateBarcode(String barcode) async {
    String query = '''
    query validateBarcode(\$barcode: String!) {
      validateBarcode(barcode: \$barcode) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {'barcode': barcode};

    final response = await _graphQLService.performVariableQueryWithCache(
        query, 'validateBarcode', variables);

    return response;
  }

  // Mutation to check in a user to an event using barcode
  static Future<Map<String, dynamic>> checkinEvent(String barcode) async {
    String mutation = '''
    mutation checkinEvent(\$barcode: String!) {
      checkinEvent(barcode: \$barcode) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {'barcode': barcode};

    final response = await _graphQLService.performMutation(
        mutation, variables, 'checkinEvent');

    return response;
  }

  // Query to get all checked-in users for a specific event
  static Future<Map<String, dynamic>> getCheckinUsersForEvent(
      String eventId) async {
    String query = '''
    query getCheckinUsersForEvent(\$eventId: String!) {
      getCheckinUsersForEvent(eventId: \$eventId) {
        message
        metadata
        success
      }
    }
    ''';

    final variables = {'eventId': eventId};

    final response = await _graphQLService.performVariableQueryWithCache(
        query, 'getCheckinUsersForEvent', variables);

    return response;
  }

  // Query to get list of all meetings/events
  static Future<Map<String, dynamic>> getMeetingsList() async {
    String query = '''
    query getMeetingsList {
      getMeetingsList {
        message
        metadata
        success
      }
    }
    ''';

    final response = await _graphQLService
        .performVariableQueryWithCache(query, 'getMeetingsList', {});

    return response;
  }
}
