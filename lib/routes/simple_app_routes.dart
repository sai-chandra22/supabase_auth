import 'package:get/get.dart';
import '../modules/home/screens/simple_splash_screen.dart';
import '../modules/home/screens/simple_login_screen.dart';
import '../modules/home/screens/simple_home_screen.dart';

class SimpleAppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';

  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SimpleSplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const SimpleLoginScreen(),
    ),
    GetPage(
      name: home,
      page: () => const SimpleHomeScreen(),
    ),
  ];
}
