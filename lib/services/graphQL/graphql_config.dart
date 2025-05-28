// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:graphql_flutter/graphql_flutter.dart';
// import 'package:mars_scanner/services/keys/api_keys.dart';

// import '../../cache/local/shared_prefs.dart';
// import 'helpers/connectivity_cube.dart';
// import 'helpers/timeout.dart';

// class GraphQLConfig {
//   static final ConnectivityCubit connectivityCubit =
//       ConnectivityCubit(Connectivity());

//   static final HttpTimeoutRetry httpLink = HttpTimeoutRetry(
//     ApiKeys.graphQLApiUrl,
//     connectivityCubit,
//     requestTimeout: const Duration(seconds: 15),
//   );

//   // static final HttpLink httpLink = HttpLink(ApiKeys.graphQLApiUrl);

//   static Future<String?> getToken() async {
//     return await LocalStorage.getGraphQLApiToken() ?? ApiKeys.unAuthToken;
//   }

//   static final CustomAuthLink authLink = CustomAuthLink(
//     getToken: getToken,
//   );

//   static final Link link = authLink.concat(httpLink);

//   static ValueNotifier<GraphQLClient> client = ValueNotifier(
//     GraphQLClient(
//       cache: GraphQLCache(store: HiveStore()),
//       link: link,
//     ),
//   );

//   static Future<QueryResult> queryWithTimeout(
//       GraphQLClient client, QueryOptions options,
//       {Duration timeout = const Duration(seconds: 10)}) {
//     return client.query(options).timeout(timeout, onTimeout: () {
//       throw TimeoutException('The request timed out after $timeout');
//     });
//   }

//   static Future<QueryResult> mutateWithTimeout(
//       GraphQLClient client, MutationOptions options,
//       {Duration timeout = const Duration(seconds: 50)}) {
//     return client.mutate(options).timeout(timeout, onTimeout: () {
//       throw TimeoutException('The request timed out after $timeout');
//     });
//   }
// }

// class CustomAuthLink extends Link {
//   final Future<String?> Function() getToken;
//   final String headerKey;

//   CustomAuthLink({
//     required this.getToken,
//     this.headerKey = 'Authorization',
//   });

//   @override
//   Stream<Response> request(Request request, [NextLink? forward]) async* {
//     final token = await getToken();

//     // Update the headers with the Authorization token
//     final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
//       (headers) => HttpLinkHeaders(
//         headers: <String, String>{
//           ...headers?.headers ?? <String, String>{},
//           if (token != null) headerKey: 'Bearer $token',
//           // Add User-Agent if present in the request context
//           if (request.context.entry<UserAgentContextEntry>() != null)
//             'User-Agent':
//                 request.context.entry<UserAgentContextEntry>()!.userAgent,
//         },
//       ),
//     );

//     // debugPrint the headers for debugging
//     debugPrint(
//         'Headers: ${updatedRequest.context.entry<HttpLinkHeaders>()?.headers}');

//     // Pass the request forward in the link chain
//     if (forward != null) {
//       yield* forward(updatedRequest);
//     }
//   }
// }

// class UserAgentContextEntry extends ContextEntry {
//   final String userAgent;

//   const UserAgentContextEntry(this.userAgent);

//   @override
//   List<Object?> get fieldsForEquality => [userAgent];
// }

// class HttpTimeoutLink extends HttpLink {
//   final Duration queryTimeout;
//   final Duration mutationTimeout;

//   HttpTimeoutLink({
//     required String uri,
//     required this.queryTimeout,
//     required this.mutationTimeout,
//   }) : super(uri);

//   @override
//   Stream<Response> request(Request request, [NextLink? forward]) async* {
//     final stream = super.request(request, forward).first.timeout(
//           request.isQuery ? queryTimeout : mutationTimeout,
//           onTimeout: () => throw TimeoutException("Request timed out"),
//         );
//     yield* stream.asStream();
//   }
// }
