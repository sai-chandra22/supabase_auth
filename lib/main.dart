// ignore_for_file: unused_element

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mars_scanner/modules/barcode_scanner/controller/barcode_scanner_controller.dart';
import 'package:mars_scanner/modules/onboarding/controller/signin_controller.dart';
import 'package:mars_scanner/modules/onboarding/controller/signup_controller.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mars_scanner/routes/app_pages.dart';
import 'package:mars_scanner/routes/app_routes.dart';
import 'package:mars_scanner/services/keys/api_keys.dart';
import 'package:mars_scanner/utils/colors.dart';
import 'package:mars_scanner/utils/nav_key.dart';
import 'package:precached_network_image/precached_network_image.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:no_screenshot/no_screenshot.dart';

import 'cache/local/shared_prefs.dart';
import 'helpers/haptics.dart';
import 'helpers/network.dart';
import 'modules/home_screen/controller/home_controller.dart';
import 'modules/home_screen/view/home_screen.dart';
import 'services/auth/token_expiry_manager.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

String getVersionWithoutBuild(String version) {
  // If version contains a build number (e.g., '3.4.8+3.4.8'), take only the part before '+'
  return version.split('+').first;
}

bool isVersionLessThan(String version1, String version2) {
  if (version1 == '0.0.0') {
    return false;
  } else {
    // Clean versions before comparing
    String cleanVersion1 = getVersionWithoutBuild(version1);
    String cleanVersion2 = getVersionWithoutBuild(version2);

    List<int> v1Parts = cleanVersion1.split('.').map(int.parse).toList();
    List<int> v2Parts = cleanVersion2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] < v2Parts[i]) return true;
      if (v1Parts[i] > v2Parts[i]) return false;
    }
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Initialize deep link handler
  Get.put(HomeController(), permanent: true);
  Get.put(BarcodeScannerController(), permanent: true);
  await HapticFeedbacks.initialize(); // This will trigger initialization
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  NetworkManager();
  final user = await LocalStorage.getUserModel();

  if (user == null) {
    await LocalStorage.clearIOSKeychain();
    await LocalStorage.clearSecureStorage();
    if (Platform.isAndroid) {
      await Hive.deleteBoxFromDisk(LocalStorage.authSessionKey);
    } else {
      await LocalStorage.clearPersistentStorageKey();
    }
  }

  await sb.Supabase.initialize(
    url: ApiKeys.supabaseUrl,
    anonKey: ApiKeys.supabaseAnonKey,
    authOptions: sb.FlutterAuthClientOptions(
      autoRefreshToken: true,
      localStorage: Platform.isIOS
          ? CustomSecureStorage(persistSessionKey: LocalStorage.authSessionKey)
          : sb.SharedPreferencesLocalStorage(
              persistSessionKey: LocalStorage.authSessionKey),
    ),
  );

  if (Platform.isIOS) {
    await TokenExpiryManager.initialize();
  }

  final prefs = await SharedPreferences.getInstance();
  String? lastVersion = prefs.getString('app_version_key_SCANNER');

  // Check if current version requires reinstallation

  debugPrint('Current app version: $lastVersion');

  // Check if current version is less than any version in the list

  runApp(Phoenix(child: const MyApp()));
}

manualLogout() async {
  debugPrint('337ssd: Manual logout triggered');
  await LocalStorage.clearLocalData();
  await LocalStorage.clearIOSKeychain();
  await LocalStorage.clearSecureStorage();
  if (Platform.isAndroid) {
    await Hive.deleteBoxFromDisk('auth_storages_SCANNER');
  } else {
    await LocalStorage.clearPersistentStorageKey();
  }
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
    PrecachedNetworkImageManager.instance.precacheNetworkImages(isLog: true);

    super.initState();
    //  _protectDataLeakageOn();
    // disableScreenshot();

    initialization();
    _checkIfUserIsLoggedIn();
  }

  void _protectDataLeakageOn() async {
    if (Platform.isIOS) {
      await ScreenProtector.protectDataLeakageWithImage('LaunchImage');
    } else if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  void initialization() async {
    await TokenExpiryManager.initialize();

    TokenExpiryManager.initialized;
    FlutterNativeSplash.remove();
  }

  final homeController = Get.find<HomeController>();
  final signUpController = Get.put(SignUpController(), permanent: true);
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
    // _protectDataLeakageOn();
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
            title: 'Mars Scanner',
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

void showReinstallDialog() {
  showDialog(
    context: AppGlobalKey.navKey.currentContext!,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('App Reinstallation Required'),
          content: const Text(
            'This update requires system level configurations. Please uninstall and reinstall the app to configure the changes.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

class ReinstallScreen extends StatelessWidget {
  const ReinstallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'App Re-installation Required',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.marsOrange600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'This version of app has been updated to new cache configuration and needed a fresh installation process to apply changes. Please install the app again after uninstalling.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.marsOrange600,
                    ),
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text('OK', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSecureStorage extends sb.LocalStorage {
  late FlutterSecureStorage _secureStorage;
  late Box<String> _hiveBox;
  final String persistSessionKey;
  bool _useHive = false;
  static final _lock =
      Lock(); // Creating a lock using the 'synchronized' package

  CustomSecureStorage({required this.persistSessionKey});

  @override
  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize both storage mechanisms
    if (Platform.isAndroid) {
      _useHive = true;
      // Initialize Hive for Android
      _hiveBox = await Hive.openBox<String>(persistSessionKey);
      debugPrint('🔥 337ssd: Hive storage initialized for Android');
    } else {
      // Use secure storage for iOS
      _secureStorage = const FlutterSecureStorage();
      debugPrint('🔥 337ssd: Secure storage initialized for iOS');
    }
  }

  @override
  Future<bool> hasAccessToken() async {
    if (_useHive) {
      final exists = _hiveBox.containsKey(persistSessionKey);
      prints('🔍 337ssd: Android has access token: $exists');
      return exists;
    } else {
      final exists = await _secureStorage.containsKey(key: persistSessionKey);
      debugPrint('🔍 337ssd: iOS has access token: $exists');
      return exists;
    }
  }

  @override
  Future<String?> accessToken() async {
    try {
      if (_useHive) {
        int retryCount = 0;
        while (!_hiveBox.isOpen && retryCount < 3) {
          prints(
              '🔑 337ssd: Hive box is closed! Attempting to reopen... (attempt ${retryCount + 1})');
          try {
            _hiveBox = await Hive.openBox<String>(persistSessionKey);
            prints('🔑 337ssd: Successfully reopened Hive box');
          } catch (e) {
            prints('🔑 337ssd: Error reopening Hive box: $e');
            retryCount++;
            await Future.delayed(
                Duration(milliseconds: 100)); // Short delay before retry
          }
        }

        final token = _hiveBox.get(persistSessionKey);
        prints('🔑 337ssd: Retrieved Android access token: ${token != null}');

        // If token is null but box is open, this might indicate a race condition
        // Let's add a short delay and try one more time
        if (token == null && _hiveBox.isOpen) {
          prints(
              '🔑 337ssd: Token not found on first attempt, retrying after delay...');
          await Future.delayed(Duration(milliseconds: 200));
          final retryToken = _hiveBox.get(persistSessionKey);
          prints('🔑 337ssd: Retry result: ${retryToken != null}');
          return retryToken;
        }

        return token;
      } else {
        final token = await _secureStorage.read(key: persistSessionKey);
        debugPrint('🔑 337ssd: Retrieved iOS access token: ${token != null}');
        return token;
      }
    } catch (e) {
      prints('🔑 337ssd: Error in Retrieving Android access token:');
      return null;
    }
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _lock.synchronized(() async {
      try {
        if (_useHive) {
          debugPrint('💾 337ssd: Storing session in Hive storage');
          await _hiveBox.put(persistSessionKey, persistSessionString);
          final stored = _hiveBox.get(persistSessionKey);
          debugPrint(
              '💾 337ssd: Verification - stored session: ${stored != null}');
        } else {
          debugPrint('💾 337ssd: Storing session in secure storage');
          await _secureStorage.write(
              key: persistSessionKey, value: persistSessionString);
        }
      } catch (e) {
        debugPrint('💾 337ssd: Error persisting session: $e');
      }
    });
  }

  @override
  Future<void> removePersistedSession() async {
    await _lock.synchronized(() async {
      if (_useHive) {
        debugPrint('🗑️ 337ssd: Removing session from Hive storage');
        await _hiveBox.delete(persistSessionKey);
      } else {
        debugPrint('🗑️ 337ssd: Removing session from secure storage');
        await _secureStorage.delete(key: persistSessionKey);
      }
    });
  }

  Future<void> clearSecureStorage() async {
    if (_useHive) {
      await _hiveBox.clear();
      debugPrint('🗑️ 337ssd: All Hive storage data cleared');
    } else {
      await _secureStorage.delete(key: persistSessionKey);
      debugPrint('🗑️ 337ssd: All secure storage data cleared');
    }
  }
}
