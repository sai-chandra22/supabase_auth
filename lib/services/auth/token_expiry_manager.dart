import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:restart/restart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:get/get.dart';
import '../../cache/local/shared_prefs.dart';
import '../../modules/home_screen/controller/home_controller.dart';
import '../../modules/home_screen/view/home_screen.dart';
import '../../utils/nav_key.dart';
import '../graphQL/queries/onboarding_queries.dart';
import '../keys/api_keys.dart';

class TokenExpiryManager with WidgetsBindingObserver {
  static final TokenExpiryManager _instance = TokenExpiryManager._internal();
  factory TokenExpiryManager() => _instance;
  static final Completer<void> _initializationCompleter = Completer<void>();
  static Future<void> get initialized => _initializationCompleter.future;

  final _supabase = sb.Supabase.instance.client;
  final homeController = Get.find<HomeController>();
  static bool _isInitialized = false;
  static Future<void>? _initializationFuture;
  sb.SupabaseClient get supabase => _supabase;
  int attemptCount = 0;
  bool isFirstTime = false;
  bool isMinimizedAndNotRefreshed = false;

  // Add these variables
  Completer<void>? _tokenRefreshCompleter;
  bool _isRefreshing = false;
  bool _isTokenValid = false;

  // Add this getter to check status
  bool get isRefreshingToken => _isRefreshing;
  bool get isTokenValid => _isTokenValid;
  bool get isInitailized => _isInitialized;

  // Add this method to wait for refresh
  Future<void> waitForTokenRefresh() async {
    if (isFirstTime) {
      if (_isRefreshing && _tokenRefreshCompleter != null) {
        await _tokenRefreshCompleter!.future;
      }
    }
  }

  StreamSubscription<sb.AuthState>? _authStateSubscription;

  TokenExpiryManager._internal(); // Empty internal constructor

  static Future<TokenExpiryManager> initialize() async {
    debugPrint('153ssd: Inside Initialize method ');
    if (!_isInitialized) {
      _initializationFuture ??= _instance._initialize();
      await _initializationFuture;
      _isInitialized = true;

      // Add observer only once
      WidgetsBinding.instance.removeObserver(_instance);
      WidgetsBinding.instance.addObserver(_instance);
    }
    return _instance;
  }

  Future<void> _initialize() async {
    debugPrint('55ssd TokenExpiryManager initializing...');
    isFirstTime = true;

    await _authStateSubscription?.cancel();

    _authStateSubscription = _supabase.auth.onAuthStateChange
        .listen(_handleAuthStateChange, cancelOnError: false);

    if (!_initializationCompleter.isCompleted) {
      _initializationCompleter.complete();
      debugPrint('55ssd TokenExpiryManager initialization complete');
    }

    // Check session status on initialization
  }

  void _handleAuthStateChange(sb.AuthState data) async {
    final session = data.session;
    final event = data.event;
    final currentSession = _supabase.auth.currentSession;
    final user = await LocalStorage.getUserModel();
    final token = await LocalStorage.getRefreshToken();

    prints(
        '55ssd 73ssd inside listenToAuthChanges session details: isSessionNull: ${session == null} refreshToken: ${session?.refreshToken}');
    prints('55ssd 73ssd inside listenToAuthChanges event: $event');
    prints(
        '55ssd 73ssd inside listenToAuthChanges currentSession: isSessionNull: ${currentSession == null} refreshToken: ${currentSession?.refreshToken}');
    prints(
        '55ssd 73ssd inside listenToAuthChanges isExpired: ${session?.isExpired}  isCurrentSessionExpired: ${currentSession?.isExpired}');
    prints(
        '55ssd 73ssd inside listenToAuthChanges stored refreshToken: ${await LocalStorage.getRefreshToken()}');

    if (session != null) {
      switch (event) {
        case sb.AuthChangeEvent.tokenRefreshed:
          _isRefreshing = true;
          _tokenRefreshCompleter = Completer<void>();
          try {
            debugPrint('Expired token refreshed successfully');
            await _saveSessionToLocal(session, true);
            callSaveTestLog(
                'Entered token refresh event: Session: $session, Event: $event',
                "Last saved token:$token",
                '${user?.firstName ?? 777}');
            _isTokenValid = true;
            isFirstTime = false;
            isMinimizedAndNotRefreshed = false;
            _tokenRefreshCompleter?.complete();
          } catch (e) {
            _tokenRefreshCompleter?.completeError(e);
            isFirstTime = false;
            _isTokenValid = false;
            isMinimizedAndNotRefreshed = false;
          } finally {
            _isRefreshing = false;
            isFirstTime = false;
            _tokenRefreshCompleter = null;
            isMinimizedAndNotRefreshed = false;
          }
          break;

        case sb.AuthChangeEvent.initialSession:
          try {
            debugPrint('Initial session - fresh launch');

            await _saveSessionToLocal(session);
            callSaveTestLog(
                'Entered initial session event: Session: $session, Event: $event',
                "Last saved token:$token",
                '${user?.firstName ?? 777}');
            isFirstTime = false;
            _isTokenValid = true;
            isMinimizedAndNotRefreshed = false;
          } catch (e) {
            debugPrint('Error saving initial session: $e');
            isFirstTime = false;
            _isTokenValid = false;
            isMinimizedAndNotRefreshed = false;
          }
          break;

        // case sb.AuthChangeEvent.signedOut:
        //   debugPrint('User signed out');

        //   break;

        case sb.AuthChangeEvent.userDeleted:
          debugPrint('User account deleted');
          //  await _clearLocalSession();
          break;

        default:
          debugPrint('Auth event: $event');
      }
    } else {
      _isTokenValid = false;
      debugPrint('73ssd session is $session, no details found');
    }
  }

  void logout() async {
    await _supabase.auth.signOut();
  }

  callSaveTestLog(String testLog, String currentToken, String name) async {
    try {
      final response =
          await OnBoardingGQLQueries.saveTestLog(testLog, currentToken, name);
      debugPrint('73ssd Test log saved successfully: $response');
      final metadata = response['metadata'];
      final success = response['success'];
      if (success != null && success == true) {
        debugPrint('73ssd Test log saved successfully: $metadata');
      } else {
        debugPrint('73ssd Failed to save test log: $metadata');
      }
    } catch (e) {
      debugPrint('73ssd Error saving test log: $e');
    }
  }

  Future<void> _saveSessionToLocal(
    sb.Session? session,
    // ignore: unused_element_parameter
    [
    bool? isTokenRefreshed,
  ]) async {
    //  final user = await LocalStorage.getUserModel();
    try {
      if (session != null) {
        await LocalStorage.setAllTokenData(
          token: session.accessToken,
          refreshToken: session.refreshToken!,
          expiresIn: session.expiresIn?.toString() ?? '',
          expiresAt: session.expiresAt.toString(),
        );

        debugPrint(isTokenRefreshed == null
            ? 'Token saved locally: AccessToken and RefreshToken updated in initial session'
            : 'Token saved locally: AccessToken and RefreshToken updated through refresh session');
      } else {
        debugPrint('No session available to save.');
      }
    } catch (e) {
      debugPrint('73ssd Error saving session to local storage: $e');
    }
  }

  bool _hasResumedOnce = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final user = await LocalStorage.getUserModel();
    final token = await LocalStorage.getRefreshToken();
    final homeController = Get.find<HomeController>();
    debugPrint(
        '55ssd :App lifecycle state condition: ${homeController.enablePrivacyMode.value == true}');

    if (state == AppLifecycleState.paused &&
        homeController.enablePrivacyMode.value == true) {
      isMinimizedAndNotRefreshed = true;
      final currentSession = _supabase.auth.currentSession;
      debugPrint('55ssd :App paused: Checking session');
      callSaveTestLog(
        'User minimized the app with subscription canceled status: ${_authStateSubscription == null} session: $currentSession',
        "Last saved token : $token",
        '${user?.firstName ?? 777}',
      );
    }

    if (state == AppLifecycleState.resumed) {
      debugPrint('55ssd :App resumed');
      isMinimizedAndNotRefreshed = false;
      if (_hasResumedOnce) return;
      _hasResumedOnce = true;
      final currentSession = _supabase.auth.currentSession;
      callSaveTestLog(
        'User resumed the app with currentSession: $currentSession',
        "Last saved token : $token",
        '${user?.firstName ?? 777}',
      );

      if (user != null) {
        final context = AppGlobalKey.navKey.currentContext;
        final session = _supabase.auth.currentSession;
        if (context != null) {
          prints(
              '73ssd APP Resume Session status - isSessionNull: $session : isExpired - ${session?.isExpired}');
          if (Platform.isIOS) {
            if (session != null && session.isExpired) {
              restart();
              _initializationFuture = null;
            } else {}
          } else {
            Phoenix.rebirth(context);
          }
        }
      }
      _hasResumedOnce = false;
    }
  }

  void dispose() {
    _authStateSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('TokenExpiryManager disposed');
  }

  Future<String> getApiToken() async {
    final session = _supabase.auth.currentSession;
    final user = await LocalStorage.getUserModel();
    try {
      if (session != null && user != null) {
        return session.accessToken;
      } else if (session == null && user != null) {
        final token = await LocalStorage.getGraphQLApiToken();
        return token ?? ApiKeys.unAuthToken;
      } else {
        return ApiKeys.unAuthToken;
      }
    } catch (e) {
      debugPrint('Error getting API token: $e');
      return ApiKeys.unAuthToken;
    }
  }
}
