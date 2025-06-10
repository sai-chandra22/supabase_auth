import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_scanner/modules/onboarding/controller/signin_controller.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mars_scanner/routes/app_pages.dart';
import 'package:mars_scanner/routes/app_routes.dart';
import 'package:mars_scanner/services/keys/api_keys.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:mars_scanner/utils/nav_key.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:no_screenshot/no_screenshot.dart';

import 'cache/local/shared_prefs.dart';
import 'helpers/haptics.dart';
import 'helpers/network.dart';
import 'services/auth/token_expiry_manager.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HapticFeedbacks.initialize();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  NetworkManager();
  final user = await LocalStorage.getUserModel();
  if (user == null) {
    await LocalStorage.clearIOSKeychain();
    await LocalStorage.clearSecureStorage();
    await LocalStorage.clearPersistentStorageKey();
  }

  await sb.Supabase.initialize(
    url: ApiKeys.supabaseUrl,
    anonKey: ApiKeys.supabaseAnonKey,
    authOptions: sb.FlutterAuthClientOptions(
      autoRefreshToken: true,
      localStorage:
          CustomSecureStorage(persistSessionKey: LocalStorage.authSessionKey),
    ),
  );

  await TokenExpiryManager.initialize();

  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    debugPrint('153ssd App initialization started');
    super.initState();
    initialization();
    _checkIfUserIsLoggedIn();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  final signInController = Get.put(SignInController(), permanent: true);

  final _noScreenshot = NoScreenshot.instance;

  void disableScreenshot() async {
    await _noScreenshot.screenshotOff();
  }

  Future<void> _checkIfUserIsLoggedIn() async {
    final user = await LocalStorage.getUserModel(); // Retrieve user data

    if (user != null) {
      try {} catch (e) {
        debugPrint('73ssd Error refreshing session: $e');
      }
    } else {
      debugPrint('733ssd User is not logged in');
      await LocalStorage.clearIOSKeychain();
      await LocalStorage.clearSecureStorage();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
            home: child,
            navigatorKey: AppGlobalKey.navKey,
            navigatorObservers: [
              routeObserver,
              // FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)
            ],
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            title: 'Supabase Auth',
            theme: ThemeData.dark().copyWith(
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xff0a0e21),
              ),
              scaffoldBackgroundColor: AppColors.background,
            ),
            getPages: AppPages.pages,
            initialRoute: AppRoutes.splashScreen,
          );
        });
  }
}

class CustomSecureStorage extends sb.LocalStorage {
  late FlutterSecureStorage _storage;
  final String persistSessionKey;

  CustomSecureStorage({required this.persistSessionKey});

  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: false,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    );
    debugPrint('🔥 337ssd: Secure storage initialized');
  }

  @override
  Future<bool> hasAccessToken() async {
    final exists = await _storage.containsKey(key: persistSessionKey);
    debugPrint('🔍 337ssd: Has access token: $exists');
    return exists;
  }

  @override
  Future<String?> accessToken() async {
    final token = await _storage.read(key: persistSessionKey);
    prints('🔑 337ssd: Retrieved access token: $token');
    return token;
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    prints('💾 337ssd: Storing session in secure storage');
    await _storage.write(key: persistSessionKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    prints('🗑️ 337ssd: Removing session from secure storage');
    await _storage.delete(key: persistSessionKey);
  }

  Future<void> clearSecureStorage() async {
    await _storage.delete(key: persistSessionKey);
    debugPrint('🗑️ 337ssd: All secure storage data cleared');
  }
}

void prints(var s1) {
  String s = s1.toString();
  final pattern = RegExp('.{1,800}');
  pattern.allMatches(s).forEach((match) => debugPrint(match.group(0)));
}
