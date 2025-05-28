import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../graphql_service.dart';
import '../unauth_service.dart';

class TrendsGQLQueries {
  static final GraphQLService _graphQLService = GraphQLService();
  static final UnAuthGraphQLService _unauthGraphQLService =
      UnAuthGraphQLService();

  // Method to fetch trends for a specific artist on a specific media platform
  static Future<Map<String, dynamic>> getArtistTrends(String artistId,
      String media, List<String> metricTypes, DateTime timestamp,
      {CancelToken? cancelToken}) async {
    // Format the timestamp to 'yyyy-MM-dd'
    String formattedTimestamp = DateFormat('yyyy-MM-dd').format(timestamp);

    String query = '''
  query viewTrendsV2Mv(\$artistId: String!, \$media: String!, \$timestamp: Date!) {
    viewTrendsV2Mv(
      where: {
        artistId: {_eq: \$artistId}, 
        media: {_eq: \$media}, 
        metricType: {_in: $metricTypes}, 
        timestamp: {_gt: \$timestamp}
      }
      order_by: {timestamp: Asc}
    ) {
      timestamp
      metricValue
      metricType
    }
  }
  ''';

    debugPrint(
        "Fetching trends for artist on \$media with metric types: $metricTypes");

    // Prepare variables for the GraphQL query
    final variables = sortKeys({
      'artistId': artistId, // The artist ID
      'media': media, // The media (e.g., Spotify)
      'timestamp': formattedTimestamp, // The formatted timestamp
    });

    final response = await _graphQLService.performMutation(
        query, variables, 'viewTrendsV2Mv', cancelToken);

    // Call the GraphQL service to perform the mutation/query
    return response;
  }

  // Method to fetch the career history of a specific artist by artistId
  static Future<Map<String, dynamic>> getArtistCareerHistory(
      String artistId) async {
    String query = '''
    query viewArtistCareerHistory(\$artistId: String!) {
      viewArtistCareerHistory(
        limit: 1,
        order_by: {lastUpdatedTimestamp: Desc},
        where: {artistId: {_eq: \$artistId}}
      ) {
        momentum
        stage
        lastUpdatedTimestamp
      }
    }
    ''';

    debugPrint("Fetching career history for artist with ID: \$artistId");

    // Prepare variables for the GraphQL query
    final variables = {
      'artistId': artistId, // The artist ID
    };

    final response = await _graphQLService.performMutation(
        query, variables, 'viewArtistCareerHistory');

    // Call the GraphQL service to perform the mutation/query
    return response;
  }

  // Method to fetch the latest metrics for a specific artist on specified media platforms
  static Future<Map<String, dynamic>> getArtistLatestMetrics(
      String artistId, List<String> media, List<String> metricTypes) async {
    String query = '''
      query viewArtistLatestMetrics(\$artistId: String!) {
        viewArtistLatestMetrics(
          where: {
            artistId: {_eq: \$artistId}, 
            media: {_in: ["Instagram", "YouTube Music", "TikTok"]}, 
            metricType: {_in: ["followers", "subscribers"]}
          },
          order_by: {timestamp: Desc}
        ) {
          media
          metricType
          metricValue
          timestamp
        }
      }
    ''';

    prints("Fetching latest metrics for artist ID: $artistId $query");

    // Prepare variables for the GraphQL query
    final variables = {
      'artistId': artistId, // The artist ID
    };

    final response = await _graphQLService.performMutation(
        query, variables, 'viewArtistLatestMetrics');

    // Call the GraphQL service to perform the query
    return response;
  }

  static void prints(var s1) {
    String s = s1.toString();
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
  }

  // Function to sort a Map's keys recursively
  static Map<String, dynamic> sortKeys(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort(); // Sort keys alphabetically
    return {
      for (var key in sortedKeys)
        key: map[key] is Map<String, dynamic>
            ? sortKeys(map[key]) // Recursively sort nested maps
            : map[key],
    };
  }

  static Future<Map<String, dynamic>> getArtistFanMetricsFollowListenerGrowth(
      String artistId) async {
    String query = '''
  query artistFanMetricsFollowListenerGrowth(\$artistId: String!) {
    artistFanMetricsFollowListenerGrowth(where: {artistId: {_eq: \$artistId}}) {
      artistId
      avgFollowersOrSubsStart
      avgListenersOrViewsStart
      avgListenersOrViewsEnd
      avgFollowersOrSubsEnd
      endSnapshotDate
      startSnapshotDate
      servicesUsedEnd
      servicesUsedStart
    }
  }
  ''';

    debugPrint(
        "Fetching artist fan metrics follow/listener growth for artist with ID: \$artistId");

    // Prepare variables for the GraphQL query
    final variables = {
      'artistId': artistId,
    };

    // Call the GraphQL service to perform the query/mutation
    final response = await _graphQLService.performMutation(
        query, variables, 'artistFanMetricsFollowListenerGrowth');

    return response;
  }

  static Future<Map<String, dynamic>>
      getArtistFanMetricsFollowListenerGrowthRaw7Day(String artistId) async {
    String query = '''
  query artistFanMetricsFollowListenerGrowthRaw7Day(\$artistId: String!) {
    artistFanMetricsFollowListenerGrowthRaw7Day(
      where: {artistId: {_eq: \$artistId}}
      order_by: {snapshotDate: Desc}
    ) {
      artistId
      metricType
      period
      serviceName
      snapshotDate
      value
    }
  }
  ''';

    debugPrint(
        "Fetching artist fan metrics follow/listener growth raw 7 day for artist with ID: \$artistId");

    // Prepare variables for the GraphQL query
    final variables = {
      'artistId': artistId,
    };

    // Call the GraphQL service to perform the query/mutation
    final response = await _graphQLService.performMutation(
        query, variables, 'artistFanMetricsFollowListenerGrowthRaw7Day');

    return response;
  }
}
